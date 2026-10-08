import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pokemon_mcts.dart';
import '../models/task.dart';
import 'ability_utils.dart';
import 'xp_utils.dart';

/// A new ability the player may swap in, offered when a Pokémon levels up
/// onto a multiple of 5.
class AbilityOffer {
  final String pokeId;
  final Map<String, dynamic> ability;
  final List<String> currentAbilityIds;

  const AbilityOffer({
    required this.pokeId,
    required this.ability,
    required this.currentAbilityIds,
  });
}

/// What the UI should celebrate after a completion toggle was persisted.
class TaskCompletionResult {
  /// The task row was saved, but some XP/level writes failed.
  final bool rewardsFailed;

  /// Row (`pokemon_name`, `type`) of the Pokémon granted for a trainer
  /// level-up, if any.
  final Map<String, dynamic>? newPokemon;

  /// "Name (Lv a → b)" for each party Pokémon that leveled up.
  final List<String> pokemonLevelUps;

  final List<AbilityOffer> abilityOffers;

  const TaskCompletionResult({
    this.rewardsFailed = false,
    this.newPokemon,
    this.pokemonLevelUps = const [],
    this.abilityOffers = const [],
  });
}

/// Pending XP/level write for one Pokémon, computed locally.
class _PokemonPlan {
  final String id;
  final Map<String, dynamic> update;
  final String? levelUpLabel;
  final List<String>? abilityExclusions; // non-null => offer an ability

  _PokemonPlan(this.id, this.update, this.levelUpLabel, this.abilityExclusions);
}

/// Persists task completion and the XP rewards that go with it using as few
/// sequential Supabase round trips as possible:
///
/// 1. task update ‖ trainer select
/// 2. trainer update ‖ one select for all party + favorite Pokémon
///    (‖ new random Pokémon, chained after the trainer update, on level-up)
/// 3. every Pokémon update ‖ ability lookups for multiple-of-5 level-ups
class TaskCompletionService {
  TaskCompletionService._();

  static const double _xpScaler = 1.1;
  static const int _xpBase = 100;

  /// +50 (75 if high priority) +25 if completed before the end date;
  /// un-completing reverts 50.
  static int xpChangeFor(Task task, {required bool completed, required DateTime now}) {
    if (!completed) return -50;
    var xp = task.highPriority ? 75 : 50;
    if (task.endDate.isAfter(now)) xp += 25;
    return xp;
  }

  /// Saves the completion state and applies trainer/Pokémon XP.
  ///
  /// Throws only when the task row itself could not be written; reward
  /// failures are reported through [TaskCompletionResult.rewardsFailed].
  static Future<TaskCompletionResult> setCompleted({
    required Task task,
    required bool completed,
    required DateTime now,
  }) async {
    final supabase = Supabase.instance.client;
    final xpChange = xpChangeFor(task, completed: completed, now: now);
    final trainerId = task.trainerId;

    final taskWrite = supabase
        .from('task_table')
        .update({
          'is_completed': completed,
          'date_completed': completed ? now.toIso8601String() : null,
        })
        .eq('task_id', task.taskId);

    if (trainerId.isEmpty) {
      await taskWrite;
      return const TaskCompletionResult();
    }

    // --- Round trip 1: task write ‖ trainer read ---------------------------
    final trainerRead = _settle(supabase
        .from('trainer_table')
        .select()
        .eq('trainer_id', trainerId)
        .maybeSingle());
    await Future.wait<void>([taskWrite, trainerRead]); // rethrows task errors
    final (trainer, trainerReadError) = await trainerRead;
    if (trainerReadError != null) {
      debugPrint('TaskCompletionService: trainer read failed: $trainerReadError');
      return const TaskCompletionResult(rewardsFailed: true);
    }
    if (trainer == null) return const TaskCompletionResult();

    // --- Trainer XP (local) -------------------------------------------------
    final completedTasks = _int(trainer['completed_tasks'], 0);
    final newCompletedTasks = completed
        ? completedTasks + 1
        : (completedTasks > 0 ? completedTasks - 1 : 0);
    final trainerXp = calculateXpAndLevel(
      currentXp: _int(trainer['experience_points'], 0),
      currentLevel: _int(trainer['level'], 1),
      xpChange: xpChange,
      scaler: _xpScaler,
      base: _xpBase,
    );

    // --- Round trip 2: trainer write ‖ party+favorite read ------------------
    final trainerWrite = _settle(supabase
        .from('trainer_table')
        .update({
          'completed_tasks': newCompletedTasks,
          'experience_points': trainerXp.newXp,
          'level': trainerXp.newLevel,
        })
        .eq('trainer_id', trainerId));

    // Only grant the level-up Pokémon once the trainer level is saved.
    final Future<Map<String, dynamic>?> newPokemon = trainerXp.levelsGained > 0
        ? trainerWrite.then((r) async => r.$2 == null ? await _grantRandomPokemon(trainerId) : null)
        : Future.value(null);

    // LinkedHashSet keeps slot order for the level-up dialog.
    final slotIds = <String>{
      for (var i = 1; i <= 6; i++)
        if (trainer['pokemon_slot_$i'] != null) trainer['pokemon_slot_$i'].toString(),
    };
    final favoriteId = trainer['favorite_pokemon']?.toString();
    final pokeIds = <String>{...slotIds, if (favoriteId != null) favoriteId}.toList();

    final Future<(PostgrestList?, Object?)> pokemonRead = pokeIds.isEmpty
        ? Future.value((const <Map<String, dynamic>>[], null))
        : _settle(supabase.from('pokemon_table').select().inFilter('pokemon_id', pokeIds));
    final (pokemonRows, pokemonReadError) = await pokemonRead;
    if (pokemonReadError != null) {
      debugPrint('TaskCompletionService: Pokémon read failed: $pokemonReadError');
    }

    // --- Pokémon XP (local), one write per Pokémon --------------------------
    final rowsById = {
      for (final row in pokemonRows ?? const <Map<String, dynamic>>[])
        row['pokemon_id'].toString(): row,
    };
    final plans = <_PokemonPlan>[];
    for (final id in pokeIds) {
      final row = rowsById[id];
      if (row == null) continue;
      final inParty = slotIds.contains(id);
      // Party members get xpChange; the favorite gets xpChange on top
      // (i.e. double when it is also in the party).
      final totalXp = (inParty ? xpChange : 0) + (id == favoriteId ? xpChange : 0);
      plans.add(_planPokemon(id, row, totalXp, inParty: inParty));
    }

    // --- Round trip 3: all Pokémon writes ‖ ability lookups -----------------
    final writes = [
      for (final p in plans)
        _settle(supabase.from('pokemon_table').update(p.update).eq('pokemon_id', p.id)),
    ];
    final lookups = [
      for (final p in plans)
        p.abilityExclusions == null
            ? Future<Map<String, dynamic>?>.value(null)
            : _lookupAbility(p.abilityExclusions!),
    ];
    final writeResults = await Future.wait(writes);
    final abilities = await Future.wait(lookups);

    final levelUps = <String>[];
    final offers = <AbilityOffer>[];
    var rewardsFailed = pokemonReadError != null;
    for (var i = 0; i < plans.length; i++) {
      final error = writeResults[i].$2;
      if (error != null) {
        debugPrint('TaskCompletionService: Pokémon ${plans[i].id} update failed: $error');
        rewardsFailed = true;
        continue; // don't celebrate a level that wasn't saved
      }
      final label = plans[i].levelUpLabel;
      if (label != null) levelUps.add(label);
      final ability = abilities[i];
      if (ability != null) {
        offers.add(AbilityOffer(
          pokeId: plans[i].id,
          ability: ability,
          currentAbilityIds: plans[i].abilityExclusions!,
        ));
      }
    }

    final (_, trainerWriteError) = await trainerWrite;
    if (trainerWriteError != null) {
      debugPrint('TaskCompletionService: trainer update failed: $trainerWriteError');
      rewardsFailed = true;
    }

    return TaskCompletionResult(
      rewardsFailed: rewardsFailed,
      newPokemon: await newPokemon,
      pokemonLevelUps: levelUps,
      abilityOffers: offers,
    );
  }

  static _PokemonPlan _planPokemon(
    String id,
    Map<String, dynamic> row,
    int xpChange, {
    required bool inParty,
  }) {
    final level = _int(row['level'], 1);
    final xp = calculateXpAndLevel(
      currentXp: _int(row['experience_points'], 0),
      currentLevel: level,
      xpChange: xpChange,
      scaler: _xpScaler,
      base: _xpBase,
    );
    final update = <String, dynamic>{
      'experience_points': xp.newXp,
      'level': xp.newLevel,
    };
    String? label;
    if (inParty && xp.levelsGained > 0) {
      // Party members also gain stats: Pokemon_mcts.levelUp() per level.
      final attack = row['attack'];
      final health = row['health'];
      if (attack is num && health is num) {
        var poke = Pokemon_mcts(
          pokemonName: '${row['pokemon_name'] ?? ''}',
          nickname: '${row['nickname'] ?? ''}',
          type: '${row['type'] ?? ''}',
          level: level,
          attack: attack.toInt(),
          maxHealth: health.toInt(),
          abilities: [],
        );
        for (var i = 0; i < xp.levelsGained; i++) {
          poke = poke.levelUp();
        }
        update['health'] = poke.maxHealth;
        update['attack'] = poke.attack;
      }
      final name = row['nickname'] ?? row['pokemon_name'] ?? 'Pokémon';
      label = '$name (Lv $level → ${xp.newLevel})';
    }
    List<String>? exclusions;
    if (xp.levelsGained > 0 && xp.newLevel % 5 == 0) {
      exclusions = [
        for (var j = 1; j <= 4; j++)
          if (row['ability$j'] != null) row['ability$j'].toString(),
      ];
    }
    return _PokemonPlan(id, update, label, exclusions);
  }

  static Future<Map<String, dynamic>?> _lookupAbility(List<String> exclude) async {
    try {
      return await fetchRandomAbilityExcluding(exclude);
    } catch (e) {
      debugPrint('TaskCompletionService: ability lookup failed: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _grantRandomPokemon(String trainerId) async {
    try {
      final newPokeId = await addRandomPokemonToTrainer(trainerId);
      if (newPokeId == null) return null;
      return await Supabase.instance.client
          .from('pokemon_table')
          .select('pokemon_name, type')
          .eq('pokemon_id', newPokeId)
          .maybeSingle();
    } catch (e) {
      debugPrint('TaskCompletionService: granting new Pokémon failed: $e');
      return null;
    }
  }

  /// Awaits [future] (starting a lazy Postgrest request immediately) and
  /// captures its error instead of throwing.
  static Future<(T?, Object?)> _settle<T>(Future<T> future) async {
    try {
      return (await future, null);
    } catch (e) {
      return (null, e);
    }
  }

  static int _int(Object? value, int fallback) =>
      value is num ? value.toInt() : fallback;
}

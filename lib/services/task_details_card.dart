import 'package:flutter/material.dart';
import 'package:poketask/services/xp_utils.dart';
import 'package:poketask/services/ability_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';
import '../models/pokemon_mcts.dart';

class TaskDetailsCard extends StatefulWidget {
  final Task task;
  const TaskDetailsCard({super.key, required this.task});

  @override
  State<TaskDetailsCard> createState() => _TaskDetailsCardState();
}

class _TaskDetailsCardState extends State<TaskDetailsCard> {
  late bool isCompleted;
  late String notes;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isCompleted = widget.task.isCompleted;
    notes = widget.task.taskNotes;
    _notesController.text = notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> updateTaskCompleted(bool completed) async {
    final supabase = Supabase.instance.client;
    final now = DateTime.now();
    await supabase
        .from('task_table')
        .update({
          'is_completed': completed,
          'date_completed': completed ? now.toIso8601String() : null,
        })
        .eq('task_id', widget.task.taskId);

    final trainerId = widget.task.trainerId;
    if (trainerId != null && trainerId.isNotEmpty) {
      final trainerResponse = await supabase
        .from('trainer_table')
        .select()
        .eq('trainer_id', trainerId)
        .maybeSingle();
      int completedTasks = (trainerResponse != null && trainerResponse['completed_tasks'] != null)
        ? trainerResponse['completed_tasks'] as int
        : 0;
      final newCompletedTasks = completed
        ? completedTasks + 1
        : (completedTasks > 0 ? completedTasks - 1 : 0);
      int trainerXp = trainerResponse?['experience_points'] ?? 0;
      int trainerLevel = trainerResponse?['level'] ?? 1;
      int xpChange = completed ? 25 : -25;
      final trainerXpResult = calculateXpAndLevel(
        currentXp: trainerXp,
        currentLevel: trainerLevel,
        xpChange: xpChange,
        scaler: 1.1,
        base: 100,
      );
      trainerXp = trainerXpResult.newXp;
      trainerLevel = trainerXpResult.newLevel;
      bool trainerLeveledUp = trainerXpResult.levelsGained > 0;
      await supabase
        .from('trainer_table')
        .update({
          'completed_tasks': newCompletedTasks,
          'experience_points': trainerXp,
          'level': trainerLevel,
        })
        .eq('trainer_id', trainerId);
      // --- Trainer level up: add random Pokémon and show dialog ---
      if (trainerLeveledUp) {
        final newPokeId = await addRandomPokemonToTrainer(trainerId);
        if (newPokeId != null) {
          final pokeRes = await supabase
            .from('pokemon_table')
            .select()
            .eq('pokemon_id', newPokeId)
            .maybeSingle();
          if (pokeRes != null && context.mounted) {
            await showNewPokemonDialog(context, pokeRes['pokemon_name'], pokeRes['type']);
          }
        }
      }
      // --- Pokémon XP/Level/Ability logic ---
      List<String> pokemonLevelUps = [];
      List<Future<void>> abilityDialogs = [];
      for (int i = 1; i <= 6; i++) {
        final slotKey = 'pokemon_slot_$i';
        final pokeId = trainerResponse?[slotKey];
        if (pokeId == null) continue;
        final pokeRes = await supabase
          .from('pokemon_table')
          .select()
          .eq('pokemon_id', pokeId)
          .maybeSingle();
        if (pokeRes == null) continue;
        int pokeXp = pokeRes['experience_points'] ?? 0;
        int pokeLevel = pokeRes['level'] ?? 1;
        final pokeXpResult = calculateXpAndLevel(
          currentXp: pokeXp,
          currentLevel: pokeLevel,
          xpChange: xpChange,
          scaler: 1.1,
          base: 100,
        );
        // Only add to level up list if level increased
        if (pokeXpResult.levelsGained > 0) {
          // Apply stat scaling for each level gained
          var tempPoke = Pokemon_mcts(
            pokemonName: pokeRes['pokemon_name'],
            nickname: pokeRes['nickname'],
            type: pokeRes['type'],
            level: pokeLevel,
            attack: pokeRes['attack'],
            maxHealth: pokeRes['health'],
            abilities: [], // Not needed for stat scaling
          );
          for (int lvl = 0; lvl < pokeXpResult.levelsGained; lvl++) {
            tempPoke = tempPoke.levelUp();
          }
          String pokeName = pokeRes['nickname'] ?? pokeRes['pokemon_name'] ?? 'Pokémon';
          pokemonLevelUps.add('$pokeName (Lv ${pokeLevel} → ${pokeXpResult.newLevel})');
          // Update DB with new XP/level and new stats
          await supabase
            .from('pokemon_table')
            .update({
              'experience_points': pokeXpResult.newXp,
              'level': pokeXpResult.newLevel,
              'health': tempPoke.maxHealth,
              'attack': tempPoke.attack,
            })
            .eq('pokemon_id', pokeId);
        } else {
          // Update DB with new XP/level only
          await supabase
            .from('pokemon_table')
            .update({
              'experience_points': pokeXpResult.newXp,
              'level': pokeXpResult.newLevel,
            })
            .eq('pokemon_id', pokeId);
        }
        // Offer new ability if new level is a multiple of 5 and at least one level was gained
        if (pokeXpResult.levelsGained > 0 && pokeXpResult.newLevel % 5 == 0) {
          List<String> currentAbilityIds = [];
          for (int j = 1; j <= 4; j++) {
            final abId = pokeRes['ability$j'];
            if (abId != null) currentAbilityIds.add(abId.toString());
          }
          final newAbility = await fetchRandomAbilityExcluding(currentAbilityIds);
          if (newAbility != null && context.mounted) {
            // Queue the dialog to show after level-up notification
            abilityDialogs.add(Future(() async {
              await Future.delayed(const Duration(seconds: 2));
              await offerAbilityDialog(
                context: context,
                ability: newAbility,
                pokeId: pokeId.toString(),
                currentAbilityIds: currentAbilityIds,
              );
            }));
          }
        }
      }
      // Show level-up notification if any
      if (pokemonLevelUps.isNotEmpty && context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pokémon Leveled Up!'),
            content: Text(pokemonLevelUps.join('\n')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      // Show ability dialogs (sequentially)
      for (final dialog in abilityDialogs) {
        await dialog;
      }
    }
    if (!mounted) return;
    setState(() {
      isCompleted = completed;
      widget.task.isCompleted = completed;
      widget.task.dateCompleted = completed ? now : DateTime(2100);
    });
    // Do not close the dialog here
  }

  Future<void> updateTaskNotes(String notes) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('task_table')
        .update({'task_notes': notes})
        .eq('task_id', widget.task.taskId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.task.highPriority == true)
            Container(
              color: Colors.red[700],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.priority_high, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'High Priority',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.task.endDate.isBefore(DateTime.now()))
            Container(
              color: Colors.orange[800],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Past Deadline',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: Text(widget.task.taskText)),
                IconButton(
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  tooltip: isCompleted ? 'Completed' : 'Mark as complete',
                  onPressed: () async {
                    await updateTaskCompleted(!isCompleted);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes:'),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add notes...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.save),
                  tooltip: 'Save Notes',
                  onPressed: () async {
                    setState(() {
                      notes = _notesController.text;
                      widget.task.taskNotes = notes;
                    });
                    await updateTaskNotes(notes);
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Text('Start: '
                '${widget.task.startDate.year}-${widget.task.startDate.month.toString().padLeft(2, '0')}-${widget.task.startDate.day.toString().padLeft(2, '0')} '
                '${widget.task.startDate.hour.toString().padLeft(2, '0')}:${widget.task.startDate.minute.toString().padLeft(2, '0')}'),
            Text('End: '
                '${widget.task.endDate.year}-${widget.task.endDate.month.toString().padLeft(2, '0')}-${widget.task.endDate.day.toString().padLeft(2, '0')} '
                '${widget.task.endDate.hour.toString().padLeft(2, '0')}:${widget.task.endDate.minute.toString().padLeft(2, '0')}'),
            SizedBox(height: 8),
            Text('Completed: ${isCompleted ? "Yes" : "No"}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(isCompleted),
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () async {
            final supabase = Supabase.instance.client;
            await supabase
                .from('task_table')
                .delete()
                .eq('task_id', widget.task.taskId);
            Navigator.of(context).pop('delete');
          },
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

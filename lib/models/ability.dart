

class Ability {
  Ability({
    required this.abilityName,
    required this.abilityId,

  });

  String abilityName;
  int abilityId;


  @override
  String toString() {
    return 'Ability{abilityName: $abilityName, abilityId: $abilityId}';
  }
}
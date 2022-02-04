class WorkoutType {
  const WorkoutType({
    required this.id,
    required this.rank,
    required this.name,
    required this.active,
    required this.exerciseIds,
  });

  final String id;
  final int rank;
  final String name;
  final bool active;
  final List<String> exerciseIds;

  static WorkoutType fromMap(Map<Object?, Object?> map) {
    return WorkoutType(
      id: map['id'] as String,
      rank: map['rank'] as int,
      name: map['name'] as String,
      active: map['active'] as bool,
      exerciseIds: (map['exercises'] as List<Object?>).map((e) => e.toString()).toList(),
    );
  }
}

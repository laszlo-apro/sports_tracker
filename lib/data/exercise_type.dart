class ExerciseType {
  const ExerciseType({
    required this.id,
    required this.name,
    required this.type,
    required this.unit,
  });

  final String id;
  final String name;
  final String type;
  final String unit;

  static ExerciseType fromMap(Map<Object?, Object?> map) {
    return ExerciseType(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      unit: map['unit'] as String,
    );
  }
}

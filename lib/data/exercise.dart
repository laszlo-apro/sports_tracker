class Exercise {
  Exercise({
    required this.typeId,
    this.weight,
    this.numSeries,
    this.numReps = 1,
  });

  final String typeId;
  final num? weight;
  final int? numSeries;
  final int numReps;

  Exercise copyWith({
    num? weight,
    int? numSeries,
    int? numReps,
  }) {
    return Exercise(
      typeId: typeId,
      weight: weight ?? this.weight,
      numSeries: numSeries ?? this.numSeries,
      numReps: numReps ?? this.numReps,
    );
  }

  static Exercise fromMap(Map<Object?, Object?> map) {
    return Exercise(
      typeId: map['id'] as String,
      weight: map['weight'] as num?,
      numSeries: map['numSeries'] as int?,
      numReps: map['numReps'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'weight': weight == 0.0 ? null : weight,
        'numSeries': numSeries == 0 ? null : numSeries,
        'numReps': numReps,
      };

  @override
  String toString() {
    return 'Exercise[typeId=$typeId, weight=$weight, numSeries=$numSeries, numReps=$numReps]';
  }
}

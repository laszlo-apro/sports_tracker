class Exercise {
  Exercise({
    required this.typeId,
    this.weight,
    this.numSeries,
    this.numReps = 1,
  });

  final String typeId;
  final double? weight;
  final int? numSeries;
  final int numReps;

  Exercise copyWith({
    double? weight,
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

  Map<String, dynamic> toMap() => {
        'weight': weight,
        'numSeries': numSeries,
        'numReps': numReps,
      };

  @override
  String toString() {
    return 'Exercise[typeId=$typeId, weight=$weight, numSeries=$numSeries, numReps=$numReps]';
  }
}

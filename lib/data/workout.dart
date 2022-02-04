import 'package:sports_tracker/data/exercise.dart';

class Workout {
  const Workout({
    required this.typeId,
    required this.dateTime,
    required this.exercises,
  });

  final String typeId;
  final DateTime dateTime;
  final List<Exercise> exercises;

  Map<String, dynamic> toMap() => {
        'workout_type_id': typeId,
        'exercises': {for (final exercise in exercises) exercise.typeId: exercise.toMap()},
      };

  @override
  String toString() {
    return 'Workout[typeId=$typeId, dateTime=$dateTime, exercises=$exercises]';
  }
}

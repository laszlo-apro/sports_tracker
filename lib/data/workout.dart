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

  static Workout fromMap(Map<Object?, Object?> map) {
    return Workout(
      typeId: map['workout_type_id'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(map['id'] as String),
      ),
      exercises: (map['exercises'] as Map<Object?, Object?>).entries.map((e) {
        final map = (e.value as Map<Object?, Object?>)..['id'] = e.key;
        return Exercise.fromMap(map);
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'workout_type_id': typeId,
        'exercises': {
          for (final exercise in exercises) exercise.typeId: exercise.toMap()
        },
      };

  @override
  String toString() {
    return 'Workout[typeId=$typeId, dateTime=$dateTime, exercises=$exercises]';
  }
}

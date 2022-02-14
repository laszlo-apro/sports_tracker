import 'package:flutter/material.dart';
import 'package:sports_tracker/data/workout_type.dart';
import 'package:sports_tracker/screen/workout/workout_screen.dart';
import 'package:sports_tracker/util/constants.dart';

class WorkoutTypeWidget extends StatelessWidget {
  const WorkoutTypeWidget({
    Key? key,
    required this.workoutType,
  }) : super(key: key);

  final WorkoutType workoutType;

  @override
  Widget build(BuildContext context) {
    if (!workoutType.active) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 16.0,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 8.0,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WorkoutScreen(
            workoutId: workoutType.id,
            workoutName: workoutType.name,
            workoutExerciseIds: workoutType.exerciseIds,
          ),
        )),
        child: ListTile(
          leading: Icon(
            iconByWorkoutTypeId[workoutType.id],
            color: colorByWorkoutTypeId[workoutType.id],
          ),
          title: Text(workoutType.name),
        ),
      ),
    );
  }
}

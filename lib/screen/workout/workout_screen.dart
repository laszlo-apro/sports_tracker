import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sports_tracker/data/exercise.dart';
import 'package:sports_tracker/data/exercise_type.dart';
import 'package:sports_tracker/data/workout.dart';
import 'package:sports_tracker/screen/workout/exercise_type_widget.dart';
import 'package:sports_tracker/util/shared_pref_helpers.dart';
import 'package:wakelock/wakelock.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    Key? key,
    required this.workoutId,
    required this.workoutName,
    required this.workoutExerciseIds,
  }) : super(key: key);

  final String workoutId;
  final String workoutName;
  final List<String> workoutExerciseIds;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late DatabaseReference _workoutTypeRef;

  late DatabaseReference _exerciseTypesRef;
  late StreamSubscription<DatabaseEvent> _exerciseTypesSubscription;
  final List<ExerciseType> _exerciseTypes = [];

  List<String> _exerciseIds = [];

  String? _selectedExerciseTypeId;
  final Map<String, Exercise> _exerciseByIdMap = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _exerciseTypesSubscription.cancel();
    Wakelock.disable();
    super.dispose();
  }

  void _init() {
    Wakelock.enable();

    _workoutTypeRef =
        FirebaseDatabase.instance.ref('workout_types/${widget.workoutId}');

    _exerciseTypesRef = FirebaseDatabase.instance.ref('exercise_types');
    _exerciseTypesSubscription = _exerciseTypesRef.onValue.listen((event) {
      setState(() {
        _exerciseTypes.clear();
        for (final entry
            in (event.snapshot.value as Map<Object?, Object?>).entries) {
          final map = (entry.value as Map<Object?, Object?>)
            ..['id'] = entry.key;
          _exerciseTypes.add(ExerciseType.fromMap(map));
        }
      });
    });

    _exerciseIds = widget.workoutExerciseIds;

    for (final exerciseId in _exerciseIds) {
      _exerciseByIdMap[exerciseId] = Exercise(typeId: exerciseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciseTypeWidgets = _exerciseTypes.isEmpty
        ? []
        : _exerciseIds.map(_buildExerciseTypeWidget).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text(widget.workoutName),
      ),
      body: _exerciseTypes.isEmpty
          ? const SizedBox()
          : ListView(
              shrinkWrap: true,
              children: [
                ...exerciseTypeWidgets,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton(
                        items:
                            _filterAndSortExerciseTypes().map((exerciseType) {
                          return DropdownMenuItem(
                            value: exerciseType.id,
                            child: Text(exerciseType.name),
                          );
                        }).toList(),
                        value: _selectedExerciseTypeId,
                        onChanged: (value) => setState(
                            () => _selectedExerciseTypeId = value.toString()),
                      ),
                      TextButton(
                        onPressed: _addExercise,
                        child: const Text('Add Exercise'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 64.0,
                    vertical: 32.0,
                  ),
                  child: ElevatedButton(
                    onPressed: _logActivity,
                    child: const Text('LOG ACTIVITY'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildExerciseTypeWidget(String exerciseId) {
    final exerciseType = _exerciseTypes.firstWhere((e) => e.id == exerciseId);

    return ExerciseTypeWidget(
      key: Key(exerciseId),
      exerciseType: exerciseType,
      weightChangedCallback: ({required double newWeight}) =>
          _changeExerciseWeight(
        exerciseId: exerciseId,
        newWeight: newWeight,
      ),
      numSeriesChangedCallback: ({required int newNumSeries}) =>
          _changeExerciseNumSeries(
        exerciseId: exerciseId,
        newNumSeries: newNumSeries,
      ),
      numRepsChangedCallback: ({required int newNumReps}) =>
          _changeExerciseNumReps(
        exerciseId: exerciseId,
        newNumReps: newNumReps,
      ),
      doneCallback: () => _finishExercise(exerciseId: exerciseId),
      dismissedCallback: () => _removeExercise(exerciseId: exerciseId),
    );
  }

  List<ExerciseType> _filterAndSortExerciseTypes() {
    return _exerciseTypes
        .where((exerciseType) => !_exerciseIds.contains(exerciseType.id))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  void _addExercise() {
    if (_selectedExerciseTypeId == null) return;

    _workoutTypeRef.update({
      'exercises': [
        ..._exerciseIds,
        _selectedExerciseTypeId!,
      ]
    });

    _exerciseByIdMap[_selectedExerciseTypeId!] =
        Exercise(typeId: _selectedExerciseTypeId!);

    setState(() {
      _exerciseIds.add(_selectedExerciseTypeId!);
      _selectedExerciseTypeId = null;
    });
  }

  void _removeExercise({required String exerciseId}) {
    _workoutTypeRef.update({
      'exercises': List.from(_exerciseIds)..remove(exerciseId),
    });

    _exerciseByIdMap.remove(exerciseId);

    setState(() => _exerciseIds.remove(exerciseId));
  }

  void _changeExerciseWeight(
      {required String exerciseId, required double newWeight}) {
    _exerciseByIdMap[exerciseId] =
        _exerciseByIdMap[exerciseId]!.copyWith(weight: newWeight);
  }

  void _changeExerciseNumSeries(
      {required String exerciseId, required int newNumSeries}) {
    _exerciseByIdMap[exerciseId] =
        _exerciseByIdMap[exerciseId]!.copyWith(numSeries: newNumSeries);
  }

  void _changeExerciseNumReps(
      {required String exerciseId, required int newNumReps}) {
    _exerciseByIdMap[exerciseId] =
        _exerciseByIdMap[exerciseId]!.copyWith(numReps: newNumReps);
  }

  void _finishExercise({required String exerciseId}) {
    setState(() => _exerciseIds.remove(exerciseId));
  }

  Future<void> _logActivity() async {
    for (final exercise in _exerciseByIdMap.values) {
      if (exercise.weight != null) {
        await writeWeight(
            exerciseId: exercise.typeId, weight: exercise.weight!.toDouble());
      }
      if (exercise.numSeries != null) {
        await writeNumSeries(
            exerciseId: exercise.typeId, numSeries: exercise.numSeries!);
      }
      await writeNumReps(
          exerciseId: exercise.typeId, numReps: exercise.numReps);
    }

    final workout = Workout(
      typeId: widget.workoutId,
      dateTime: DateTime.now(),
      exercises: _exerciseByIdMap.values.toList(),
    );

    await FirebaseDatabase.instance
        .ref('workouts')
        .child(workout.dateTime.millisecondsSinceEpoch.toString())
        .set(workout.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activity successfully logged.'),
      ),
    );

    Navigator.of(context).pop();
  }
}

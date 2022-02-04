import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sports_tracker/data/workout_type.dart';
import 'package:sports_tracker/screen/home/workout_type_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseReference _workoutTypesRef;
  late StreamSubscription<DatabaseEvent> _workoutTypesSubscription;
  final List<WorkoutType> _workoutTypes = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _workoutTypesSubscription.cancel();
    super.dispose();
  }

  Future<void> init() async {
    _workoutTypesRef = FirebaseDatabase.instance.ref('workout_types');

    _workoutTypesSubscription = _workoutTypesRef.onValue.listen((event) {
      setState(() {
        _workoutTypes.clear();
        for (final entry in (event.snapshot.value as Map<Object?, Object?>).entries) {
          final map = (entry.value as Map<Object?, Object?>)..['id'] = entry.key;
          _workoutTypes.add(WorkoutType.fromMap(map));
        }
        _workoutTypes.sort((a, b) => a.rank.compareTo(b.rank));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: _workoutTypes.map((workoutType) => WorkoutTypeWidget(workoutType: workoutType)).toList(),
        ),
      ),
    );
  }
}

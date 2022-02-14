import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sports_tracker/data/workout_type.dart';
import 'package:sports_tracker/screen/analytics/analytics_screen.dart';
import 'package:sports_tracker/screen/home/workout_type_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  late int _currentPageIndex;

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
    _pageController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    _pageController = PageController();
    _currentPageIndex = 0;

    _workoutTypesRef = FirebaseDatabase.instance.ref('workout_types');
    _workoutTypesSubscription = _workoutTypesRef.onValue.listen((event) {
      setState(() {
        _workoutTypes.clear();
        for (final entry
            in (event.snapshot.value as Map<Object?, Object?>).entries) {
          final map = (entry.value as Map<Object?, Object?>)
            ..['id'] = entry.key;
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
      body: PageView(
        children: [
          _buildHomeContent(),
          _buildAnalyticsContent(),
        ],
        controller: _pageController,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
        ],
        onTap: _onCurrentPageIndexChanged,
      ),
    );
  }

  void _onCurrentPageIndexChanged(int newPageIndex) {
    setState(() => _currentPageIndex = newPageIndex);
    _pageController.animateToPage(
      newPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Widget _buildHomeContent() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: _workoutTypes
            .map((workoutType) => WorkoutTypeWidget(workoutType: workoutType))
            .toList(),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return const AnalyticsScreen();
  }
}

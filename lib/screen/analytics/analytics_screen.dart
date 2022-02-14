import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sports_tracker/data/workout.dart';
import 'package:sports_tracker/data/workout_chart_item.dart';
import 'package:sports_tracker/util/chart_helpers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late String _rangeUnit;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;
  late String _title;
  late List<WorkoutChartItem> _chartItems;

  @override
  void initState() {
    super.initState();
    _rangeUnit = '';
    _onRangeUnitPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  child: const Text('Prev'),
                  onPressed: _onPrevPressed,
                ),
                TextButton(
                  child: Text(_rangeUnit),
                  onPressed: _onRangeUnitPressed,
                ),
                OutlinedButton(
                  child: const Text('Next'),
                  onPressed: _onNextPressed,
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              title: ChartTitle(text: _title),
              primaryXAxis: CategoryAxis(),
              series: [
                StackedBarSeries<WorkoutChartItem, String>(
                  dataSource: _chartItems,
                  xValueMapper: (item, _) => item.formattedDate,
                  yValueMapper: (item, _) => item.cumulatedValue,
                  pointColorMapper: (item, _) => item.color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onRangeUnitPressed() {
    setState(() {
      _rangeUnit = _rangeUnit == 'Week' ? 'Month' : 'Week';
    });
    _updateDisplay();
    _retrieveWorkouts();
  }

  void _onPrevPressed() {
    final referenceDate = _rangeUnit == 'Week'
        ? _rangeStart.subtract(oneWeek)
        : DateTime(
            _rangeStart.year,
            _rangeStart.month - 1,
            _rangeStart.day,
          );
    _updateDisplay(referenceDate: referenceDate);
    _retrieveWorkouts();
  }

  void _onNextPressed() {
    final referenceDate = _rangeUnit == 'Week'
        ? _rangeStart.add(oneWeek)
        : DateTime(
            _rangeStart.year,
            _rangeStart.month + 1,
            _rangeStart.day,
          );
    _updateDisplay(referenceDate: referenceDate);
    _retrieveWorkouts();
  }

  void _updateDisplay({DateTime? referenceDate}) {
    final inputDate = referenceDate ?? DateTime.now();
    setState(() {
      _rangeStart = getFirstDayOf(
        rangeUnit: _rangeUnit,
        referenceDate: inputDate,
      );
      _rangeEnd = getLastDayOf(
        rangeUnit: _rangeUnit,
        referenceDate: inputDate,
      );
      _title = formatDateRange(
        start: _rangeStart,
        end: _rangeEnd,
        rangeUnit: _rangeUnit,
      );
      _chartItems = [];
    });
  }

  Future<void> _retrieveWorkouts() async {
    final event = await FirebaseDatabase.instance
        .ref('workouts')
        .orderByKey()
        .startAfter(_rangeStart.millisecondsSinceEpoch.toString())
        .endBefore(_rangeEnd.millisecondsSinceEpoch.toString())
        .once();

    final workouts = <Workout>[];
    for (final entry
        in ((event.snapshot.value ?? {}) as Map<Object?, Object?>).entries) {
      final map = (entry.value as Map<Object?, Object?>)..['id'] = entry.key;
      workouts.add(Workout.fromMap(map));
    }

    setState(() {
      _chartItems = generateChartItems(
        workouts: workouts,
        rangeStart: _rangeStart,
        rangeEnd: _rangeEnd,
        rangeUnit: _rangeUnit,
      );
    });
  }
}

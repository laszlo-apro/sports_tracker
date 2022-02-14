import 'package:intl/intl.dart';
import 'package:sports_tracker/data/workout.dart';
import 'package:sports_tracker/data/workout_chart_item.dart';
import 'package:sports_tracker/util/constants.dart';

const oneDay = Duration(days: 1);
const oneWeek = Duration(days: 7);

final _dateFormatMonthDay = DateFormat('MMM d');
final _dateFormatMonthDayLong = DateFormat('MMM d\nEEE');
final _dateFormatYearMonthDay = DateFormat('yyyy MMM d');
final _dateFormatYearMonth = DateFormat('yyyy MMMM');

DateTime getFirstDayOf({
  required String rangeUnit,
  DateTime? referenceDate,
}) {
  final inputDate = referenceDate ?? DateTime.now();
  if (rangeUnit == 'Week') {
    final resultDate = inputDate.subtract(
      Duration(days: inputDate.weekday - 1),
    );
    return DateTime(resultDate.year, resultDate.month, resultDate.day);
  } else {
    return DateTime(inputDate.year, inputDate.month, 1);
  }
}

DateTime getLastDayOf({
  required String rangeUnit,
  DateTime? referenceDate,
}) {
  final inputDate = referenceDate ?? DateTime.now();
  if (rangeUnit == 'Week') {
    final resultDate = inputDate.add(
      Duration(days: DateTime.daysPerWeek - inputDate.weekday),
    );
    return DateTime(
        resultDate.year, resultDate.month, resultDate.day, 23, 59, 59);
  } else {
    return DateTime(inputDate.year, inputDate.month + 1, 0, 23, 59, 59);
  }
}

String formatDateRange({
  required DateTime start,
  required DateTime end,
  required String rangeUnit,
}) {
  return rangeUnit == 'Week'
      ? '${_dateFormatYearMonthDay.format(start)} - ${_dateFormatYearMonthDay.format(end)}'
      : _dateFormatYearMonth.format(start);
}

List<WorkoutChartItem> generateChartItems({
  required List<Workout> workouts,
  required DateTime rangeStart,
  required DateTime rangeEnd,
  required String rangeUnit,
}) {
  final workoutsByDate = <DateTime, List<Workout>>{};

  for (var date = rangeStart;
      date.compareTo(rangeEnd) <= 0;
      date = date.add(oneDay)) {
    workoutsByDate[date] = [];
  }

  for (final workout in workouts) {
    final workoutDate = DateTime(
      workout.dateTime.year,
      workout.dateTime.month,
      workout.dateTime.day,
    );
    workoutsByDate[workoutDate]!.add(workout);
  }

  final workoutChartItems = <WorkoutChartItem>[];

  for (final entry in workoutsByDate.entries) {
    final formattedDate =
        (rangeUnit == 'Week' ? _dateFormatMonthDayLong : _dateFormatMonthDay)
            .format(entry.key);

    if (entry.value.isEmpty) {
      workoutChartItems.add(WorkoutChartItem(
        formattedDate: formattedDate,
        cumulatedValue: null,
        color: null,
      ));
      continue;
    }

    var cumulatedValue = 0.0;
    var tempChartItems = <WorkoutChartItem>[];
    for (final workout in entry.value.reversed) {
      cumulatedValue += _calculateWorkoutValue(workout: workout);
      tempChartItems.add(WorkoutChartItem(
        formattedDate: formattedDate,
        cumulatedValue: cumulatedValue,
        color: colorByWorkoutTypeId[workout.typeId],
      ));
    }
    workoutChartItems.addAll(tempChartItems.reversed);
  }

  return workoutChartItems;
}

double _calculateWorkoutValue({required Workout workout}) {
  var value = 0.0;
  for (final exercise in workout.exercises) {
    value += exercise.numReps * (exercise.numSeries ?? 1);
  }
  return value;
}

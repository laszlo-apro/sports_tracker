import 'package:flutter/material.dart';

class WorkoutChartItem {
  WorkoutChartItem({
    required this.formattedDate,
    required this.cumulatedValue,
    required this.color,
  });

  final String formattedDate;
  final double? cumulatedValue;
  final Color? color;
}

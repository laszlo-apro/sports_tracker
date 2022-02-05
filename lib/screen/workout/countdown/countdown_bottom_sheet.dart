import 'package:flutter/material.dart';
import 'package:sports_tracker/util/countdown_timer.dart';
import 'package:sports_tracker/util/shared_pref_helpers.dart';

class CountdownBottomSheet extends StatefulWidget {
  const CountdownBottomSheet({
    Key? key,
    required this.exerciseId,
    required this.seconds,
  }) : super(key: key);

  final String exerciseId;
  final int seconds;

  @override
  State<CountdownBottomSheet> createState() => _CountdownBottomSheetState();
}

class _CountdownBottomSheetState extends State<CountdownBottomSheet> {
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();

    _secondsLeft = widget.seconds;

    _startCountdownTimerDelayed(
      exerciseId: widget.exerciseId,
      seconds: widget.seconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _secondsLeft.toString(),
        style: const TextStyle(fontSize: 96.0),
      ),
    );
  }

  void _startCountdownTimerDelayed({
    required String exerciseId,
    required int seconds,
  }) {
    final timer = CountdownTimer();
    timer.init(
      seconds: seconds,
      tickCallback: (secondsLeft) => setState(() => _secondsLeft = secondsLeft),
      doneCallback: () async {
        await writeNumReps(exerciseId: exerciseId, numReps: seconds);
        await Future.delayed(const Duration(seconds: 3));
        timer.dispose();
        Navigator.of(context).pop();
      },
    );
    timer.startDelayed();
  }
}

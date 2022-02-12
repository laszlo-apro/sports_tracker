import 'package:flutter/material.dart';
import 'package:sports_tracker/data/exercise_type.dart';
import 'package:sports_tracker/screen/workout/countdown/countdown_bottom_sheet.dart';
import 'package:sports_tracker/screen/workout/modifier_button_widget.dart';
import 'package:sports_tracker/util/shared_pref_helpers.dart';

class ExerciseTypeWidget extends StatefulWidget {
  const ExerciseTypeWidget({
    Key? key,
    required this.exerciseType,
    required this.weightChangedCallback,
    required this.numSeriesChangedCallback,
    required this.numRepsChangedCallback,
    required this.doneCallback,
    required this.dismissedCallback,
  }) : super(key: key);

  final ExerciseType exerciseType;
  final void Function({required double newWeight}) weightChangedCallback;
  final void Function({required int newNumSeries}) numSeriesChangedCallback;
  final void Function({required int newNumReps}) numRepsChangedCallback;
  final void Function() doneCallback;
  final void Function() dismissedCallback;

  @override
  State<ExerciseTypeWidget> createState() => _ExerciseTypeWidgetState();
}

class _ExerciseTypeWidgetState extends State<ExerciseTypeWidget> {
  double _weight = 0.0;
  int _numSeries = 0;
  int _numReps = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _initExercise();
    });
  }

  Future<void> _initExercise() async {
    final weight = await readWeight(exerciseId: widget.exerciseType.id);
    final numSeries = await readNumSeries(exerciseId: widget.exerciseType.id);
    final numReps = await readNumReps(exerciseId: widget.exerciseType.id);

    widget.weightChangedCallback(newWeight: weight);
    widget.numSeriesChangedCallback(newNumSeries: numSeries);
    widget.numRepsChangedCallback(newNumReps: numReps);

    setState(() {
      _weight = weight;
      _numSeries = numSeries;
      _numReps = numReps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timed = widget.exerciseType.type == 'timed';
    final counted = widget.exerciseType.type == 'counted';
    final measured = widget.exerciseType.type == 'measured';

    final titleText =
        '${widget.exerciseType.name}${counted ? '\n/ $_weight kg' : ''}';
    final subtitleText =
        '${timed || counted ? '$_numSeries x ' : ''}$_numReps ${widget.exerciseType.unit}';

    return Dismissible(
      key: Key(widget.exerciseType.id),
      onDismissed: (direction) => _onDismissed(direction),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 8.0,
        child: ListTile(
          title: Column(
            children: [
              Text(
                titleText,
                textAlign: TextAlign.center,
              ),
              if (counted)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ModifierButtonWidget(
                        callback: () => _addWeight(-1.25),
                        label: '-',
                      ),
                      const SizedBox(width: 8.0),
                      ModifierButtonWidget(
                        callback: () => _addWeight(1.25),
                        label: '+',
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(subtitleText),
              ),
              const SizedBox(height: 4.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (timed || counted)
                    ModifierButtonWidget(
                      callback: () => _addNumSeries(-1),
                      label: '-',
                    ),
                  if (timed || counted) const SizedBox(width: 8.0),
                  if (timed || counted)
                    ModifierButtonWidget(
                      callback: () => _addNumSeries(1),
                      label: '+',
                    ),
                  if (timed || counted) const SizedBox(width: 24.0),
                  ModifierButtonWidget(
                    callback: () => _addNumReps(-1),
                    label: '-',
                  ),
                  const SizedBox(width: 8.0),
                  ModifierButtonWidget(
                    callback: () => _addNumReps(1),
                    label: '+',
                  ),
                ],
              ),
            ],
          ),
          trailing: measured
              ? const SizedBox()
              : FloatingActionButton.small(
                  onPressed: () => _onActionButtonPressed(
                    timed: timed,
                    counted: counted,
                    exerciseId: timed ? widget.exerciseType.id : null,
                    numReps: timed ? _numReps : null,
                  ),
                  heroTag: widget.exerciseType.id,
                  child: Icon(timed ? Icons.arrow_right : Icons.done),
                ),
        ),
      ),
    );
  }

  void _addWeight(double amount) {
    double newWeight = _weight + amount;
    widget.weightChangedCallback(newWeight: newWeight);
    setState(() => _weight = newWeight);
  }

  void _addNumSeries(int amount) {
    int newNumSeries = _numSeries + amount;
    widget.numSeriesChangedCallback(newNumSeries: newNumSeries);
    setState(() => _numSeries = newNumSeries);
  }

  void _addNumReps(int amount) {
    int newNumReps = _numReps + amount;
    widget.numRepsChangedCallback(newNumReps: newNumReps);
    setState(() => _numReps = newNumReps);
  }

  void _onDismissed(DismissDirection direction) {
    if (direction != DismissDirection.startToEnd) return;
    widget.dismissedCallback();
  }

  void _onActionButtonPressed({
    bool timed = false,
    bool counted = false,
    String? exerciseId,
    int? numReps,
  }) {
    if (timed) {
      _showCountdownBottomSheet(exerciseId: exerciseId!, seconds: numReps!);
    } else if (counted) {
      _showConfirmationDialog();
    }
  }

  void _showCountdownBottomSheet({
    required String exerciseId,
    required int seconds,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CountdownBottomSheet(
        exerciseId: exerciseId,
        seconds: seconds,
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Finish exercise?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('NO'),
              ),
              TextButton(
                onPressed: () {
                  widget.doneCallback();
                  Navigator.of(context).pop();
                },
                child: const Text('YES'),
              ),
            ],
          ),
        );
      },
    );
  }
}

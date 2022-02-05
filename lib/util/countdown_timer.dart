import 'dart:async';

import 'package:just_audio/just_audio.dart';

class CountdownTimer {
  static final _keySeconds = [300, 240, 180, 150, 120, 90, 60, 30, 10, 0];
  static const _oneSecond = Duration(seconds: 1);

  int _secondsLeft = 0;
  late void Function(int secondsLeft) _tickCallback;
  late void Function() _doneCallback;
  late AudioPlayer _audioPlayer;
  late Timer _timer;

  void init({
    required int seconds,
    required void Function(int secondsLeft) tickCallback,
    required void Function() doneCallback,
  }) {
    _secondsLeft = seconds;
    _tickCallback = tickCallback;
    _doneCallback = doneCallback;
    _audioPlayer = AudioPlayer();
  }

  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
  }

  Future<void> startDelayed() async {
    await Future.delayed(const Duration(seconds: 3));

    _timer = Timer.periodic(
      _oneSecond,
      (timer) async {
        _tickCallback(_secondsLeft);
        if (_secondsLeft == 0) {
          _timer.cancel();
          _doneCallback();
        } else {
          _secondsLeft--;
          if (_keySeconds.contains(_secondsLeft)) {
            _playSecondsLeftSound();
          }
        }
      },
    );
  }

  Future<void> _playSecondsLeftSound() async {
    await _audioPlayer.setAsset('assets/audio/seconds-$_secondsLeft.mp3');
    _audioPlayer.play();
  }
}

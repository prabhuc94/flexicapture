import 'dart:async';
import 'dart:math' as m;
import 'package:flexicapture/app_helper_screen_capture.dart';
import 'package:flutter/foundation.dart';

import 'flexicapture_platform_interface.dart';

class Flexicapture {
  Future<String?> getPlatformVersion() {
    return FlexicapturePlatform.instance.getPlatformVersion();
  }

  StreamController<Uint8List> _screenShotController = StreamController.broadcast(sync: true);
  Stream<Uint8List> get screenShotListen => _screenShotController.stream;
  StreamController<int> _randomMinController = StreamController.broadcast(sync: true);
  Stream<int> get randomMinController => _randomMinController.stream;

  int _maxMinute = 5;
  int _maxSize = 400 * 1024;
  Duration? _randomDuration;
  bool _isStartTimer = false;
  bool _enableCompress = true;
  bool _pauseCapture = false;
  double fixedRatio = 0.6;
  double randomRatio = 0.4;

  /// Start the TIMER once [maxSize] [maxMinute] value added properly.
  void start() {
    if (kDebugMode) {
      print("FLEXICAPTURE: TIMER-SET:[$_isActiveRandomDuration][$_isStartTimer]");
    }
    if (_isStartTimer == false && _isActiveRandomDuration) {
      _isStartTimer = true;
      _startTimer();
    }
  }

  void _startTimer() async {
    if (_isActiveRandomDuration) {
      var duration = randomDuration;
      if (kDebugMode) {
        print("FLEXICAPTURE: RANDOM-DURATION[${duration.inMinutes}]");
      }
      await Future.delayed(duration);
      _setRandomValue((duration.inMinutes));
      if (pauseCapture == false) {
        // CAPTURING
        _setValue(await ScreenshotHelper.captureScreenShot(
            maxBytes: maxSize, compress: enableCompress));
      } else {
        if (kDebugMode) {
          print("FLEXICAPTURE: PAUSE-CAPTURE[$pauseCapture]");
        }
        _setValue(null);
      }
    }
  }

  set maxMinute(int value) {
    _maxMinute = (value > 0) ? value : 5;
    _randomDuration = Duration(minutes: _captureMin);
    if (kDebugMode) {
      print("FLEXICAPTURE: RANDOM-MIN-SET[$_captureMin][$_isActiveRandomDuration][$_isStartTimer]");
    }
  }

  Duration get randomDuration => Duration(minutes: _captureMin);

  bool get _isActiveRandomDuration => (randomDuration.inMinutes > 0);

  int get _captureMin => _fixedMin(_maxMinute) + _randomMin(_maxMinute);

  int _fixedMin(int value) => (value * fixedRatio).round();

  int _randomMin(int value) {
    var minute = (value * randomRatio).round();
    m.Random random = m.Random();
    var count = random.nextInt(minute);
    return count;
  }

  void _setRandomValue(int value) {
    if (_randomMinController.isClosed) {
      _randomMinController = StreamController.broadcast(sync: true);
    }
    _randomMinController.sink.add(value);
  }


  bool get enableCompress => _enableCompress;

  set enableCompress(bool value) {
    _enableCompress = value;
    if (kDebugMode) {
      print("FLEXICAPTURE: COMPRESS-ENABLE[$value]");
    }
  }

  void _setValue(Uint8List? value) {
    if (_screenShotController.isClosed) {
      _screenShotController = StreamController.broadcast(sync: true);
    }
    if (value != null && value.isNotEmpty) {
      _screenShotController.sink.add(value);
    }
    _startTimer();
  }


  // SET VALUE MULTIPLIED BY [1024] LIKE 400 KB REQUIRED THEN [400 * 1024]
  set maxSize(int value) => _maxSize = value;
  int get maxSize => _maxSize;


  set pauseCapture(bool value) => _pauseCapture = value;
  bool get pauseCapture => _pauseCapture;

  void dispose() {
    _screenShotController.close();
    _randomMinController.close();
    _isStartTimer = false;
    _randomDuration = null;
  }
}

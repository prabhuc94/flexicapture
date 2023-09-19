
import 'dart:async';
import 'dart:math' as m;
import 'dart:typed_data';
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

  int _maxMinute = 0;
  int _maxSize = 400 * 1024;
  Duration? _randomDuration;
  bool _isStartTimer = false;
  bool _enableCompress = true;
  bool _pauseCapture = false;

  /// Start the TIMER once [maxSize] [maxMinute] value added properly.
  void start() {
    if (kDebugMode) {
      print("TIMER-SET:[$_isActiveRandomDuration][$_isStartTimer]");
    }
    if (_isStartTimer == false && _isActiveRandomDuration) {
      _isStartTimer = true;
      _startTimer();
    }
  }

  void _startTimer() async {
    if (_isActiveRandomDuration) {
      await Future.delayed(randomDuration!);
      _setRandomValue((_randomDuration?.inMinutes ?? 0));
      if (_pauseCapture == false) {
        // CAPTURING
        _setValue(await ScreenshotHelper.captureScreenShot(
            maxBytes: maxSize, compress: enableCompress));
      }
    }
  }

  set maxMinute(int value) {
    _maxMinute = value;
    var randomMin = _randomMin(value);
    _randomDuration = Duration(minutes: randomMin);
    if (kDebugMode) {
      print("RANDOM-MIN-SET:[$randomMin][$_isActiveRandomDuration][$_isStartTimer]");
    }
  }

  Duration? get randomDuration => _randomDuration;

  bool get _isActiveRandomDuration => (_randomDuration != null && ((_randomDuration?.inMinutes ?? 0) > 0));

  int _randomMin(int value) {
    m.Random random = m.Random();
    var count = random.nextInt(value) + 1;
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
  set maxSize(int value) {
    _maxSize = value;
  }


  int get maxSize => _maxSize;


  set pauseCapture(bool value) {
    _pauseCapture = value;
  }

  void dispose() {
    _screenShotController.close();
    _randomMinController.close();
    _isStartTimer = false;
    _randomDuration = null;
  }
}

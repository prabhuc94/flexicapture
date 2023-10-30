import 'dart:async';
import 'dart:math' as m;
import 'package:flexicapture/app_helper_screen_capture.dart';
import 'package:flutter/foundation.dart';

import 'flexicapture_platform_interface.dart';

class Flexicapture {
  Future<String?> getPlatformVersion() {
    return FlexicapturePlatform.instance.getPlatformVersion();
  }

  int _maxMinute = 5;
  int _maxSize = 400 * 1024;
  Duration? _randomDuration;
  bool _isStartTimer = false;
  bool _enableCompress = true;
  bool _pauseCapture = false;
  double fixedRatio = 0.6;
  double randomRatio = 0.4;
  bool captureWithAppDetails = true;
  bool convertBase64 = true;
  String? exceptAppName;

  Function(ScreenShotModel?)? _onCaptured;
  Function(String)? _onCapturedError;
  Function(Uint8List)? onScreenShot;
  Function(int)? onRandomMinutes;

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
        if (captureWithAppDetails) {
          _updateValueWithAppName(await ScreenshotHelper.captureScreenShotWithAppName(
              maxBytes: maxSize, compress: enableCompress, isConvertBase64: convertBase64));
        } else {
          _setValue(await ScreenshotHelper.captureScreenShot(
              maxBytes: maxSize, compress: enableCompress));
        }
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

  void _setRandomValue(int value) => onRandomMinutes?.call(value);


  bool get enableCompress => _enableCompress;

  set enableCompress(bool value) {
    _enableCompress = value;
    if (kDebugMode) {
      print("FLEXICAPTURE: COMPRESS-ENABLE[$value]");
    }
  }

  void _setValue(Uint8List? value) {
    if (value != null && value.isNotEmpty) {
      onScreenShot?.call(value);
    }
    _startTimer();
  }

  void _updateValueWithAppName(ScreenShotModel value) {
    if (value.imageByte?.isNotEmpty ?? false) {
      // UPDATE WITH EVENT MODE
      if (exceptAppName == null || (exceptAppName?.isEmpty ?? false) || !(value.windowInfo?.appName?.toLowerCase().startsWith("$exceptAppName".toLowerCase()) ?? false)) {
        _onCaptured?.call(value);
      } else {
        _onCapturedError?.call("${"$exceptAppName"[0].toUpperCase()}${exceptAppName?.substring(1)} is focused");
      }
    }
    _startTimer();
  }


  // SET VALUE MULTIPLIED BY [1024] LIKE 400 KB REQUIRED THEN [400 * 1024]
  set maxSize(int value) => _maxSize = value;
  int get maxSize => _maxSize;

  set pauseCapture(bool value) => _pauseCapture = value;
  bool get pauseCapture => _pauseCapture;


  set onCaptured(Function(ScreenShotModel?) value) => _onCaptured = value;

  set onCaptureError(Function(String) value) => _onCapturedError = value;

  void dispose() {
    _isStartTimer = false;
    _randomDuration = null;
  }
}

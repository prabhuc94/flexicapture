import 'dart:async';
import 'dart:math' as m;
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flexicapture/disposable.dart';
import 'package:flexicapture/app_helper_screen_capture.dart';

class FlexiCapture extends Disposable {

  int _maxMinute = 5;
  int maxSize = 400 * 1024;
  bool isStartTimer = false;
  bool enableCompress = true;
  bool pauseCapture = false;
  double fixedRatio = 0.6;
  double randomRatio = 0.4;
  bool captureWithAppDetails = true;
  bool convertBase64 = true;
  String? exceptAppName;
  bool useMicroTask = false;

  late Logger _logger;

  ValueChanged<ScreenShotModel?>? _onCaptured;
  ValueChanged<String>? _onCapturedError;
  ValueChanged<Uint8List>? onScreenShot;
  ValueChanged<int>? onRandomMinutes;

  /// Start the TIMER once [maxSize] [maxMinute] value added properly.
  void start({bool microTask = false}) {
    useMicroTask = microTask;
    _logD = "Timer set [$_isActiveRandomDuration] [$isStartTimer]";
    if (isDisposed) {
      isDisposed = false;
      _logD = "Restarted";
    }
    if (isStartTimer == false && _isActiveRandomDuration) {
      isStartTimer = true;
      _logD = "Capture timer started";
      _startTimer();
    }
  }

  void _startTimer() async {
    if (isDisposed || (!_isActiveRandomDuration) || pauseCapture) {
      _logD = "Capturing ${isDisposed ? "already disposed" : ": "}${(!_isActiveRandomDuration) ? "Random duration disabled" : " "}${pauseCapture ? "paused" : ""}";
      return;
    }
    var duration = randomDuration;
    _logD = "Random duration [${duration.inMinutes}] Will Capture at [${DateTime.now().add(duration).toIso8601String()}]";
    await Future.delayed(duration);
    if (isDisposed || pauseCapture) {
      _logD = "Disposed capture functionality";
      return;
    }
    _setRandomValue((duration.inMinutes));
    // CAPTURING
    if (captureWithAppDetails) {
      if (useMicroTask) {
        _captureAndUpdate();
      } else {
        _updateValueWithAppName(
            await ScreenshotHelper.captureScreenShotWithAppName(
                maxBytes: maxSize,
                compress: enableCompress,
                isConvertBase64: convertBase64));
      }
    } else {
      _setValue(await ScreenshotHelper.captureScreenShot(
          maxBytes: maxSize, compress: enableCompress));
    }
  }

  set maxMinute(int value) {
    _maxMinute = (value > 0) ? value : 5;
    _logD = "Maximum minutes set [$_captureMin] [$_isActiveRandomDuration] [$isStartTimer]";
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

  void _setValue(Uint8List? value) {
    if (value != null && value.isNotEmpty) onScreenShot?.call(value);
    _logW = "Captured and value passed ${(value != null && value.isNotEmpty)}";
    _startTimer();
  }

  void _captureAndUpdate() async {
    var val = await Future.microtask(() => ScreenshotHelper.captureScreenShotWithAppName(
        maxBytes: maxSize, compress: enableCompress, isConvertBase64: convertBase64));
    _updateValueWithAppName(val);
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
    _logW = "Captured and value with app name";
    _startTimer();
  }

  void onPause() {
    pauseCapture = !pauseCapture;
    _loge = "Capturing pausing ${pauseCapture ? "enabled" : "disabled"}";
  }

  void onCompress() {
    enableCompress = !enableCompress;
    _loge = "Compressing ${enableCompress ? "enabled" : "disabled"}";
  }

  void onConvert() {
    convertBase64 = !convertBase64;
    _loge = "Convert Base64 ${convertBase64 ? "enabled" : "disabled"}";
  }

  set onCaptured(Function(ScreenShotModel?) value) => _onCaptured = value;

  set onCaptureError(Function(String) value) => _onCapturedError = value;

  set _logD(dynamic message) => _logger.d("$message");

  set _loge(dynamic message) => _logger.e("$message");

  set _logW(dynamic message) => _logger.w("$message");

  @override
  void initState() {
    super.initState();
    _logger = Logger(printer: PrettyPrinter());
    _logD = "FlexiCapture: Initialized";
  }

  @override
  void onDispose() {
    super.onDispose();
    isStartTimer = false;
    _logD = "FlexiCapture: Disposed";
  }
}

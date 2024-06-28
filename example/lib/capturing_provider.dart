import 'package:flexicapture/app_helper_screen_capture.dart';
import 'package:flexicapture/flexicapture.dart';
import 'package:flutter/foundation.dart';

class CapturingProvider extends ChangeNotifier {
  late FlexiCapture _flexiCapture;
  int maxMin = 3;
  bool pauseCapture = false, enableCompress = true, convertBase64 = false, captureDisposed = false;
  ScreenShotModel? capturedModel;
  CapturingProvider() {
    _flexiCapture = FlexiCapture();
    _flexiCapture
      ..maxMinute = maxMin
      ..enableCompress = enableCompress
      ..pauseCapture = pauseCapture
      ..convertBase64 = convertBase64
      ..maxSize = 400 * 1024
      ..exceptAppName = "flexitrac";
    _flexiCapture
      ..onCaptured = (val) {
        capturedModel = val;
        notifyListeners();
      }
      ..onCaptureError = (val) {};
    onStart();
  }

  void onStart() {
    _flexiCapture.start();
    captureDisposed = _flexiCapture.isDisposed;
    notifyListeners();
  }

  void onIncrease() {
    maxMin++;
    _flexiCapture.maxMinute = maxMin;
  }

  void onConvert() {
    _flexiCapture.onConvert();
    convertBase64 = _flexiCapture.convertBase64;
    notifyListeners();
  }

  void onPause() {
    _flexiCapture.onPause();
    pauseCapture = _flexiCapture.pauseCapture;
    notifyListeners();
  }

  void onCompress() {
    _flexiCapture.onCompress();
    enableCompress = _flexiCapture.enableCompress;
    notifyListeners();
  }

  void onRestart() {
    _flexiCapture.start();
    captureDisposed = _flexiCapture.isDisposed;
    notifyListeners();
  }

  void onCapture() async {
    var result = await Future.microtask(ScreenshotHelper.captureScreenShotWithAppName);
    capturedModel = result;
    notifyListeners();
  }

  void onDispose() {
    _flexiCapture.dispose();
    captureDisposed = true;
  }
}

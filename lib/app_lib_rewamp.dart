import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:screen_capturer/screen_capturer.dart';

class ScreenCapture {
  ScreenCapture._();

  /// The shared instance of [ScreenCapture].
  static final ScreenCapture instance = ScreenCapture._();

  ScreenCapturerPlatform get _platform => ScreenCapturerPlatform.instance;

  /// Checks whether the current process already has screen capture access
  ///
  /// macOS only
  Future<bool> isAccessAllowed() async {
    return await _platform.isAccessAllowed();
  }

  /// Requests screen capture access
  ///
  /// macOS only
  Future<void> requestAccess({bool onlyOpenPrefPane = false}) {
    return ScreenCapturerPlatform.instance.requestAccess(
      onlyOpenPrefPane: onlyOpenPrefPane,
    );
  }

  /// Reads an image from the clipboard
  ///
  /// Returns a [Uint8List] object
  Future<Uint8List?> readImageFromClipboard() {
    return ScreenCapturerPlatform.instance.readImageFromClipboard();
  }

  /// Captures the screen and saves it to the specified [imagePath]
  ///
  /// Returns a [CapturedData] object with the image path, width, height and base64 encoded image
  Future<Uint8List?> capture({
    CaptureMode mode = CaptureMode.region,
    String? imagePath,
    bool copyToClipboard = false,
    bool silent = true,
  }) async {
    File? imageFile;
    if (imagePath != null) {
      imageFile = File(imagePath);
      if (!imageFile.parent.existsSync()) {
        imageFile.parent.create(recursive: true);
      }
    }
    if (copyToClipboard) {
      // 如果是复制到剪切板，先清空剪切板，避免结果不正确
      Clipboard.setData(const ClipboardData(text: ''));
    }
    await _platform.systemScreenCapturer.capture(
      mode: mode,
      imagePath: imagePath,
      copyToClipboard: copyToClipboard,
      silent: silent,
    );

    Uint8List? imageBytes;
    if (imageFile != null && imageFile.existsSync()) {
      imageBytes = imageFile.readAsBytesSync();
      imageFile.deleteSync(recursive: true);
    }
    if (copyToClipboard) {
      imageBytes = await readImageFromClipboard();
    }

    if (imageBytes != null) {
      return imageBytes;
    }
    return null;
  }
}

/// The shared instance of [ScreenCapture].
final screenCapture = ScreenCapture.instance;

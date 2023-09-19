import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screen_capturer/src/capture_mode.dart';
import 'package:screen_capturer/src/captured_data.dart';
import 'package:screen_capturer/src/screen_capturer_platform_interface.dart';
import 'package:screen_capturer/src/system_screen_capturer.dart';
import 'package:screen_capturer/src/system_screen_capturer_impl_linux.dart';
import 'package:screen_capturer/src/system_screen_capturer_impl_macos.dart';
import 'package:screen_capturer/src/system_screen_capturer_impl_windows.dart'
if (dart.library.html) 'system_screen_capturer_impl_windows_noop.dart';

class ScreenCapture {
  ScreenCapture._() {
    if (!kIsWeb && Platform.isLinux) {
      _systemScreenCapturer = SystemScreenCapturerImplLinux();
    } else if (!kIsWeb && Platform.isMacOS) {
      _systemScreenCapturer = SystemScreenCapturerImplMacOS();
    } else if (!kIsWeb && Platform.isWindows) {
      _systemScreenCapturer = SystemScreenCapturerImplWindows();
    }
  }

  /// The shared instance of [ScreenCapture].
  static final ScreenCapture instance = ScreenCapture._();

  late SystemScreenCapturer _systemScreenCapturer;

  /// Checks whether the current process already has screen capture access
  ///
  /// macOS only
  Future<bool> isAccessAllowed() {
    return ScreenCapturerPlatform.instance.isAccessAllowed();
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
    await _systemScreenCapturer.capture(
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

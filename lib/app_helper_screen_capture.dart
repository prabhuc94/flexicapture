import 'dart:convert';
import 'dart:io';
import 'package:active_window/active_window.dart';
import 'package:active_window/active_window_info.dart';
import 'package:flexicapture/app_lib_rewamp.dart';
import 'package:flexicapture/app_service_image_compress.dart';
import 'package:flutter/foundation.dart' as f;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

class ScreenshotHelper {
  ScreenshotHelper._();

  static Future<ScreenShotModel> captureScreenShotWithAppName(
      {int maxBytes = 400 * 1024,
      bool compress = true,
      bool isConvertBase64 = true}) async {
    var windowInfo = await ActiveWindow().getActiveWindow();
    if (windowInfo == null || windowInfo.appName == null || (windowInfo.appName?.isEmpty ?? false)) {
      await Future.delayed(const Duration(seconds: 10));
      windowInfo = await ActiveWindow().getActiveWindow();
    }
    Directory directory = await getTemporaryDirectory();
    String imageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    String imagePath = '${directory.path}/capture/$imageName';
    var screenShotData = await f.compute(_screenshot,
        [RootIsolateToken.instance!, maxBytes, imagePath, compress]);
    var base64 =
        (isConvertBase64) ? await f.compute(convertBase64, screenShotData) : "";
    return ScreenShotModel.name(screenShotData, windowInfo, base64);
  }

  static Future<String?> convertBase64(dynamic data) async {
    if (data is Uint8List?) {
      if (data?.isNotEmpty ?? false) {
        return base64Encode(data ?? []);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<Uint8List?> captureScreenShot(
      {int maxBytes = 400 * 1024, bool compress = true}) async {
    Directory directory = await getTemporaryDirectory();
    String imageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    String imagePath = '${directory.path}/capture/$imageName';
    return await f.compute(_screenshot,
        [RootIsolateToken.instance!, maxBytes, imagePath, compress]);
  }

  static Future<Uint8List?> _screenshot(dynamic data) async {
    RootIsolateToken? rootToken;
    int maxSize = 400 * 1024;
    String? imagePath;
    bool compress = true;
    if (data is List) {
      rootToken = data[0];
      maxSize = data[1];
      imagePath = data[2];
      compress = data[3];
    }

    if (rootToken == null || imagePath == null || imagePath.isEmpty) {
      return null;
    }
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
    Uint8List? memoryImage;
    try {
      var screenShot = await screenCapture.capture(
          mode: CaptureMode.screen, imagePath: imagePath);
      if (screenShot != null && screenShot.isNotEmpty) {
        if (compress) {
          memoryImage = await f.compute(_compress1, [screenShot, maxSize]);
        } else {
          memoryImage = screenShot;
        }
      }
      return memoryImage;
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> capture(
      {CaptureMode mode = CaptureMode.screen, int maxSize = 400 * 1024}) async {
    Uint8List? memoryImage;
    try {
      Directory directory = await getTemporaryDirectory();
      String imageName =
          'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
      String imagePath = '${directory.path}/flexitrac/Screenshots/$imageName';
      var screenShot = await ScreenCapture.instance
          .capture(mode: mode, imagePath: imagePath);
      if (screenShot != null && screenShot.isNotEmpty) {
        if (screenShot.isNotEmpty) {
          memoryImage = await f.compute(_compress1, [screenShot, maxSize]);
        }
      }
      return memoryImage;
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> _compress1(dynamic data) async {
    Uint8List? imageFile;
    int maxSize = 400 * 1024;
    if (data is List) {
      imageFile = data[0];
      maxSize = data[1];
    }
    if (imageFile == null || imageFile.isEmpty) {
      return imageFile;
    }
    int inputByte = (imageFile.lengthInBytes);
    return (inputByte > maxSize)
        ? await f.compute(ImageCompressor.compress, [imageFile, maxSize])
        : imageFile;
  }
}

class ScreenShotModel {
  Uint8List? imageByte;
  ActiveWindowInfo? windowInfo;
  String? base64Image;

  ScreenShotModel.name(this.imageByte, this.windowInfo, this.base64Image);
}

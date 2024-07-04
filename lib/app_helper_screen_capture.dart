import 'dart:convert';
import 'package:active_window/active_window_info.dart';
import 'package:active_window/active_window_platform_interface.dart';
import 'package:desktop_screenshot/desktop_screenshot.dart';
import 'package:desktop_screenshot/desktop_screenshot_platform_interface.dart';
import 'package:flexicapture/app_service_image_compress.dart';
import 'package:flutter/foundation.dart' as f;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenshotHelper {
  ScreenshotHelper._();

  static Future<ScreenShotModel> captureScreenShotWithAppName(
      {int maxBytes = 400 * 1024,
      bool compress = true,
      bool isConvertBase64 = true}) async {
    var windowInfo = await Future.microtask(ActiveWindowPlatform.instance.getActiveWindow);
    if (windowInfo == null || (windowInfo.appName == null || (windowInfo.appName?.isEmpty ?? false)) || (windowInfo.title.isEmpty)) {
      await Future.delayed(Durations.medium3);
      windowInfo = await Future.microtask(ActiveWindowPlatform.instance.getActiveWindow);
    }
    var screenshot = await Future.microtask(DesktopScreenshotPlatform.instance.getScreenshot);
    var screenShotData = await f.compute(_compress1,
        [screenshot, maxBytes]);
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
    var screenshot = await DesktopScreenshot().getScreenshot();
    return await f.compute(_compress1,
        [screenshot, maxBytes]);
  }

  static Future<Uint8List?> capture(
      {int maxSize = 400 * 1024}) async {
    Uint8List? memoryImage;
    try {
      var screenShot = await DesktopScreenshot().getScreenshot();
      if (screenShot != null && screenShot.isNotEmpty) {
        memoryImage = await f.compute(_compress1, [screenShot, maxSize]);
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

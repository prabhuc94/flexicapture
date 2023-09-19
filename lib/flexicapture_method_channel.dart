import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flexicapture_platform_interface.dart';

/// An implementation of [FlexicapturePlatform] that uses method channels.
class MethodChannelFlexicapture extends FlexicapturePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flexicapture');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

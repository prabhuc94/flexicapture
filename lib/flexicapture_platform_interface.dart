import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flexicapture_method_channel.dart';

abstract class FlexicapturePlatform extends PlatformInterface {
  /// Constructs a FlexicapturePlatform.
  FlexicapturePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlexicapturePlatform _instance = MethodChannelFlexicapture();

  /// The default instance of [FlexicapturePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlexicapture].
  static FlexicapturePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlexicapturePlatform] when
  /// they register themselves.
  static set instance(FlexicapturePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

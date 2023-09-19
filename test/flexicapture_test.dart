import 'package:flutter_test/flutter_test.dart';
import 'package:flexicapture/flexicapture.dart';
import 'package:flexicapture/flexicapture_platform_interface.dart';
import 'package:flexicapture/flexicapture_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlexicapturePlatform
    with MockPlatformInterfaceMixin
    implements FlexicapturePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlexicapturePlatform initialPlatform = FlexicapturePlatform.instance;

  test('$MethodChannelFlexicapture is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlexicapture>());
  });

  test('getPlatformVersion', () async {
    Flexicapture flexicapturePlugin = Flexicapture();
    MockFlexicapturePlatform fakePlatform = MockFlexicapturePlatform();
    FlexicapturePlatform.instance = fakePlatform;

    expect(await flexicapturePlugin.getPlatformVersion(), '42');
  });
}

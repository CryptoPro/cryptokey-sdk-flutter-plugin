import 'package:flutter_test/flutter_test.dart';
import 'package:cpkey/cpkey.dart';
import 'package:cpkey/cpkey_platform_interface.dart';
import 'package:cpkey/cpkey_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCpkeyPlatform
    with MockPlatformInterfaceMixin
    implements CpkeyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CpkeyPlatform initialPlatform = CpkeyPlatform.instance;

  test('$MethodChannelCpkey is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCpkey>());
  });

  test('getPlatformVersion', () async {
    Cpkey cpkeyPlugin = Cpkey();
    MockCpkeyPlatform fakePlatform = MockCpkeyPlatform();
    CpkeyPlatform.instance = fakePlatform;

    expect(await cpkeyPlugin.getPlatformVersion(), '42');
  });
}

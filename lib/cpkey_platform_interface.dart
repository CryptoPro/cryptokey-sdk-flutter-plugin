import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cpkey_method_channel.dart';

abstract class CpkeyPlatform extends PlatformInterface {
  /// Constructs a CpkeyPlatform.
  CpkeyPlatform() : super(token: _token);

  static final Object _token = Object();

  static CpkeyPlatform _instance = MethodChannelCpkey();

  /// The default instance of [CpkeyPlatform] to use.
  ///
  /// Defaults to [MethodChannelCpkey].
  static CpkeyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CpkeyPlatform] when
  /// they register themselves.
  static set instance(CpkeyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

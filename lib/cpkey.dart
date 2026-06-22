
import 'cpkey_platform_interface.dart';

class Cpkey {
  Future<String?> getPlatformVersion() {
    return CpkeyPlatform.instance.getPlatformVersion();
  }
}

import '../CpKeyPlugin.dart';

class SigningKey {

  final SigningKeyHostApi _hostApi = SigningKeyHostApi();

  Future<List<DSSSigningKeyInfo>> listKeys(bool checkAllContainers) async {
    return await _hostApi.listKeys(checkAllContainers);
  }
}

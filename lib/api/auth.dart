import 'dart:ffi';

import '../CpKeyPlugin.dart';

class Auth {
  final AuthHostApi _hostApi = AuthHostApi();

  Future<List<DssUser>> getAuthList() async {
    return await _hostApi.getAuthList();
  }

  Future<ScanQrResult> scanQr(String? base64Qr) async {
    return await _hostApi.scanQr(base64Qr);
  }

  Future<void> confirm(String kid) async {
    return await _hostApi.confirm(kid);
  }

  Future<void> verifyDevice(String kid, bool silent) async {
    return await _hostApi.verifyDevice(kid, silent);
  }

  Future<String> kinit(
    DssUser dssUser,
    DSSRegisterInfo registerInfo,
    DSSProtectionType keyProtectionType,
    String? activationCode,
    String? password,
  ) async {
    return await _hostApi.kinit(
      dssUser,
      registerInfo,
      keyProtectionType,
      activationCode,
      password,
    );
  }
}


import 'dart:typed_data';

import '../src/generated/crypto_pro_dss_api.g.dart';

class CryptoProDss {
  final CryptoProDssHostApi _hostApi = CryptoProDssHostApi();

  Future<SdkInitResult> init({Uint8List? rootCerts}) async {
    final response = await _hostApi.sdkInit(
      SdkInitRequest(rootCertsCmsSignature: rootCerts),
    );
    return response;
  }

  Future<bool> initBioRng() async {
    final response = await _hostApi.initBioRng();
    return response;
  }
}

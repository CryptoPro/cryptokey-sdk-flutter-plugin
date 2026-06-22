import '../CpKeyPlugin.dart';

class Cert {
  final CertHostApi _hostApi = CertHostApi();

  Future<List<DSSCertificate>> getCertList(String kid) async {
    return await _hostApi.getCertList(kid);
  }

  Future<void> deleteCert(DeleteCertRequest request) async {
    return await _hostApi.deleteCert(request);
  }
}

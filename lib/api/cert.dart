import '../CpKeyPlugin.dart';

class Cert {
  final CertHostApi _hostApi = CertHostApi();

  Future<List<DSSCertificate>> getCertList(String kid) async {
    return await _hostApi.getCertList(kid);
  }

  Future<void> deleteCert(DeleteCertRequest request) async {
    return await _hostApi.deleteCert(request);
  }

  Future<DSSCertificate> getCert(GetCertRequest request) async {
    return await _hostApi.getCert(request);
  }

  Future<DSSCertificate> getClientCert(GetCertRequest request) async {
    return await _hostApi.getClientCert(request);
  }

  Future<SignRequestResult> signRequest(SignRequestRequest request) async {
    return await _hostApi.signRequest(request);
  }

  Future<DSSCertificate> sendSignRequest(SendSignRequestRequest request) async {
    return await _hostApi.sendSignRequest(request);
  }

  Future<void> installCertificate(InstallCertificateRequest request) async {
    return await _hostApi.installCertificate(request);
  }
}

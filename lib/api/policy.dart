import '../CpKeyPlugin.dart';

class Policy {
  final PolicyHostApi _hostApi = PolicyHostApi();

  Future<DssPolicyPayload> getParamDss(String serverUrl) async {
    final response = await _hostApi.getParamsDss(serverUrl);
    return response;
  }

  Future<DssOperationsInfo> getOperations(GetOperationsRequest request) async {
    final response = await _hostApi.getOperations(request);
    return response;
  }
}

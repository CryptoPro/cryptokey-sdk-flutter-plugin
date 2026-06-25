import '../CpKeyPlugin.dart';

class Sign {

  final SignHostApi _hostApi = SignHostApi();

  Future<DssSignMtResult> signMt(
    String kid,
    DssOperation? operation,
    bool enableMultiSelection,
    DssConfirmationSendingMode confirmationSendingMode,
    String? pinCode,
    bool silent,
  ) async {
    final response = await _hostApi.signMt(
      kid,
      operation,
      enableMultiSelection,
      confirmationSendingMode,
      pinCode,
      silent,
    );
    return response;
  }
}

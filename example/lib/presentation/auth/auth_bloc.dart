import 'dart:math';

import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/navigation_service.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final NavigationService _navigationService;

  AuthBloc(this._navigationService) : super(AuthInitial()) {
    on<StartAuth>((event, emit) async {
      final qrData = await CpKeyPlugin.auth.scanQr(null);
      if (qrData.isCancelled == true) {
        emit(ShowError(message: "Scan qr is canceled"));
      } else {
        emit(AuthLoading());
        final serverUrl = qrData.qr?.data?.serviceUrl ?? "" + "/";
        final paramsDss = await CpKeyPlugin.policy.getParamDss(serverUrl);
        final dssUser = DssUser(name: "Flatter User", serviceUrl: serverUrl);
        final registerInfo = DSSRegisterInfo(
          pushAddress: "empty flutter",
          appVersion: "1",
          deviceName: "flutter device",
        );
        final kid = await CpKeyPlugin.auth.kinit(
          dssUser,
          registerInfo,
          DSSProtectionType.password,
          "",
          "",
        );
        await CpKeyPlugin.auth.confirm(kid);
        await CpKeyPlugin.auth.verifyDevice(kid, false);
        _navigationService.replaceWith(AppRoutes.main);
      }
    });
  }
}

abstract class AuthEvent {}

class StartAuth extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);
}

class ShowError extends AuthState {
  final String message;

  ShowError({required this.message});
}

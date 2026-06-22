import 'dart:math';

import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../navigation/app_routes.dart';
import '../navigation/navigation_service.dart';

@injectable
class StartBloc extends Bloc<StartEvent, StartState> {
  final NavigationService _navigationService;

  StartBloc(this._navigationService) : super(StartInitial()) {
    on<Initialization>((event, emit) async {
      emit(StartLoading());
      final SdkInitResult result = await CpKeyPlugin.cryptoProDss.init(
        rootCerts: null,
      );

      switch (result.code) {
        case SdkInitCode.initOk:
          final passed = await CpKeyPlugin.cryptoProDss.initBioRng();
          if (passed) {
            final List<DssUser> users = await CpKeyPlugin.auth.getAuthList();
            if (users.isNotEmpty) {
              _navigationService.replaceWith(AppRoutes.main);
            } else {
              _navigationService.replaceWith(AppRoutes.auth);
            }
          } else {
            emit(ShowError(message: "error when initBioRng"));
          }
        default:
          emit(
            ShowError(
              message: "Error when SDK init() ${result.code?.name ?? "code not provided"}",
            ),
          );
      }
    });
  }
}

abstract class StartEvent {}

class Initialization extends StartEvent {}

abstract class StartState {}

class StartInitial extends StartState {}

class StartLoading extends StartState {}

class ShowError extends StartState {
  final String message;

  ShowError({required this.message});
}

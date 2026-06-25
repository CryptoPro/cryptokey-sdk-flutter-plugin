import 'dart:math';

import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class OperationsBloc extends Bloc<OperationsEvent, OperationsState> {
  DssUser? activeUser;

  OperationsBloc() : super(OperationsInitial()) {
    on<LoadOperations>((event, emit) async {
      emit(OperationsLoading());
      final authList = await CpKeyPlugin.auth.getAuthList();
      activeUser = authList
          .where((element) => element.state?.toUpperCase() == 'ACTIVE')
          .firstOrNull;
      final request = GetOperationsRequest(kid: activeUser!.kid!);
      final operations = await CpKeyPlugin.policy.getOperations(request);
      emit(
        OperationsLoaded(
          operations.operations.whereType<DssOperation>().toList(),
        ),
      );
    });

    on<OpenOperation>((event, emit) async {
      final result = await CpKeyPlugin.sign.signMt(
        activeUser!.kid!,
        event.operation,
        false,
        DssConfirmationSendingMode.online,
        null,
        false,
      );
      emit(OperationSuccess(result));
    });
  }
}

abstract class OperationsEvent {}

class LoadOperations extends OperationsEvent {}

class OpenOperation extends OperationsEvent {
  final DssOperation operation;

  OpenOperation({required this.operation});
}

abstract class OperationsState {}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final List<DssOperation> operations;

  OperationsLoaded(this.operations);
}

class OperationSuccess extends OperationsState {
  final DssSignMtResult result;

  OperationSuccess(this.result);
}

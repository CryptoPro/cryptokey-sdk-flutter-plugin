import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class KeysBloc extends Bloc<KeysEvent, KeysState> {

  KeysBloc() : super(KeysInitial()) {
    on<FetchKeysEvent>((event, emit) async {
      emit(KeysLoading());
      try {
        final keys = await CpKeyPlugin.signingKey.listKeys(event.checkAllContainers);
        emit(KeysLoaded(keys));
      } catch (e) {
        emit(KeysError(e.toString()));
      }
    });
  }
}

abstract class KeysEvent {}

class FetchKeysEvent extends KeysEvent {
  final bool checkAllContainers;
  FetchKeysEvent({this.checkAllContainers = false});
}

abstract class KeysState {}

class KeysInitial extends KeysState {}

class KeysLoading extends KeysState {}

class KeysLoaded extends KeysState {
  final List<DSSSigningKeyInfo> keys;
  KeysLoaded(this.keys);
}

class KeysError extends KeysState {
  final String message;
  KeysError(this.message);
}
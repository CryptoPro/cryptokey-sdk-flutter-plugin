
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState(currentIndex: 0)) {
    on<TabChanged>((event, emit) {
      emit(MainState(currentIndex: event.index));
    });
  }
}

abstract class MainEvent {}

class TabChanged extends MainEvent {
  final int index;
  TabChanged(this.index);
}

class MainState {
  final int currentIndex;
  MainState({required this.currentIndex});
}
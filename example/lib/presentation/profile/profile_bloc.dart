import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../navigation/app_routes.dart';
import '../../navigation/navigation_service.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final NavigationService _navigationService;
  DssUser? activeUser;

  ProfileBloc(this._navigationService) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      final users = await CpKeyPlugin.auth.getAuthList();
      activeUser = users
          .where((element) => element.state?.toUpperCase() == 'ACTIVE')
          .firstOrNull;
      emit(ProfileLoaded(user: activeUser!));
    });

    on<LogoutRequested>((event, emit) async {
      await CpKeyPlugin.auth.removeAuth(
        RemoveAuthRequest(
          kid: activeUser!.kid!,
          deletedKid: activeUser!.kid!,
          forceDelete: true,
        ),
      );
      _navigationService.replaceWith(AppRoutes.auth);
    });
  }
}

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class LogoutRequested extends ProfileEvent {}

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final DssUser user;

  ProfileLoaded({required this.user});
}

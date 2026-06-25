import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../navigation/app_routes.dart';
import '../../navigation/navigation_service.dart';

@injectable
class CertsBloc extends Bloc<CertsEvent, CertsState> {
  DssUser? activeUser;
  final NavigationService _navigationService;

  CertsBloc(this._navigationService) : super(CertsInitial()) {
    on<LoadCerts>((event, emit) async {
      emit(CertsLoading());
      final authList = await CpKeyPlugin.auth.getAuthList();
      activeUser = authList
          .where((element) => element.state?.toUpperCase() == 'ACTIVE')
          .firstOrNull;
      final certList = await CpKeyPlugin.cert.getCertList(
        activeUser?.kid ?? "",
      );
      emit(CertsLoaded(certList));
    });

    on<DeleteCert>((event, emit) async {
      final request = DeleteCertRequest(
        cid: event.cid,
        rid: event.rid,
        removeFromToken: false,
        kid: activeUser!.kid!,
        silent: false,
      );
      await CpKeyPlugin.cert.deleteCert(request);
      add(LoadCerts());
    });

    on<CreateCert>((event, emit) async {
      await _navigationService.navigateTo(AppRoutes.create_cert);
      add(LoadCerts());
    });
  }
}

abstract class CertsEvent {}

class LoadCerts extends CertsEvent {}

class CreateCert extends CertsEvent {}

class DeleteCert extends CertsEvent {
  final String? rid;
  final String? cid;

  DeleteCert(this.rid, this.cid);
}

abstract class CertsState {}

class CertsInitial extends CertsState {}

class CertsLoading extends CertsState {}

class CertsLoaded extends CertsState {
  final List<DSSCertificate> certs;

  CertsLoaded(this.certs);
}

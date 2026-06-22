import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CertsBloc extends Bloc<CertsEvent, CertsState> {
  DssUser? activeUser;

  CertsBloc() : super(CertsInitial()) {
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
        cid: event.id,
        rid: event.id,
        removeFromToken: false,
        kid: activeUser!.kid!,
        silent: false,
      );
      await CpKeyPlugin.cert.deleteCert(request);
      add(LoadCerts());
    });
  }
}

abstract class CertsEvent {}

class LoadCerts extends CertsEvent {}

class DeleteCert extends CertsEvent {
  final String? id;

  DeleteCert(this.id);
}

abstract class CertsState {}

class CertsInitial extends CertsState {}

class CertsLoading extends CertsState {}

class CertsLoaded extends CertsState {
  final List<DSSCertificate> certs;

  CertsLoaded(this.certs);
}

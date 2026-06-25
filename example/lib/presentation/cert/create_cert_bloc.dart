import 'dart:async';
import 'dart:math';

import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:collection/collection.dart';

import '../../navigation/navigation_service.dart';

const String nameKey = '2.5.4.3';
const String nameCountry = '2.5.4.6';

@injectable
class CreateCertBloc extends Bloc<CreateCertsEvent, CreateCertState> {
  DssUser? activeUser;
  final NavigationService _navigationService;

  CreateCertBloc(this._navigationService) : super(CertParamsLoading()) {
    on<LoadCertParams>(_onLoadCertParams);
    on<SubmitCreateCert>(_onSubmitCreateCert);
    on<Exit>((event, emit) async {
      _navigationService.goBack();
    });
    add(LoadCertParams());
  }

  Future<void> _onLoadCertParams(
    LoadCertParams event,
    Emitter<CreateCertState> emit,
  ) async {
    emit(CertParamsLoading());
    try {
      final authList = await CpKeyPlugin.auth.getAuthList();
      activeUser = authList
          .where((element) => element.state?.toUpperCase() == 'ACTIVE')
          .firstOrNull;

      if (activeUser == null || activeUser!.kid == null) {
        emit(CertError(message: 'Активный пользователь не найден'));
        return;
      }

      final caParams = await CpKeyPlugin.policy.getCaParams(activeUser!.kid!);

      final isMobileKeysSupported = caParams.isMobileKeysSupported ?? false;
      final isDssKeysSupported = caParams.isDskKeysSupported ?? false;
      final isServerKeysSupported = caParams.isServerKeysSupported ?? false;

      final certAvailableStorage = <KeyStorageType>[];
      if (activeUser!.authKeyType == 1 && isDssKeysSupported) {
        certAvailableStorage.add(KeyStorageType.distributed);
      } else {
        if (isMobileKeysSupported) {
          certAvailableStorage.add(KeyStorageType.mobile);
        }
        if (isServerKeysSupported) {
          certAvailableStorage.add(KeyStorageType.cloud);
        }
      }
      final formData = CreateCertFormData(
        policies: caParams.caPolicies,
        certAvailableStorage: certAvailableStorage,
      );

      emit(CertParamsLoaded(formData: formData));
    } catch (e) {
      emit(CertError(message: e.toString()));
    }
  }

  Future<void> _onSubmitCreateCert(
    SubmitCreateCert event,
    Emitter<CreateCertState> emit,
  ) async {
    emit(CertCreating());
    try {
      await issueCertificate(
        kid: activeUser!.kid!,
        caId: event.caId,
        templateId: event.templateId,
        subjectName: event.name,
        storageType: event.certStorage,
      );
      emit(CertCreated());
    } catch (e) {
      emit(CertError(message: e.toString()));
    }
  }

  Future<void> issueCertificate({
    required String kid,
    required int caId,
    required String templateId,
    required String subjectName,
    required KeyStorageType storageType,
  }) async {
    // 1. Проверяем, разрешён ли выпуск из МП
    final params = await CpKeyPlugin.policy.getParamDss(
      activeUser!.serviceUrl!,
    );
    if (params.clientSignEnrollmentEnabled == false) {
      throw Exception('Выпуск сертификата из МП запрещён настройками сервера');
    }

    // 2. Проверяем наличие необработанных запросов
    final certList = await CpKeyPlugin.cert.getCertList(activeUser!.kid!);
    final pendingRequests = certList.where(
      (c) =>
          c.type == CertType.Req.name &&
          (c.state == CertState.PENDING.name ||
              c.state == CertState.SIGN_WAIT.name),
    );
    if (pendingRequests.isNotEmpty) {
      throw Exception(
        'Есть необработанные запросы. Дождитесь обработки или удалите их.',
      );
    }

    // 3. Выпуск в зависимости от типа хранения
    switch (storageType) {
      case KeyStorageType.cloud:
        await _issueCloudCertificate(kid, caId, templateId, subjectName);
        break;
      case KeyStorageType.mobile:
        await _issueMobileCertificate(
          kid,
          caId,
          templateId,
          subjectName,
          DSSCryptoKeyContainerType.device,
        );
        break;
      case KeyStorageType.distributed:
        await _issueMobileCertificate(
          kid,
          caId,
          templateId,
          subjectName,
          DSSCryptoKeyContainerType.distributed,
        );
        break;
    }
  }

  // ========================
  // CLOUD (ключ на сервере)
  // ========================

  Future<void> _issueCloudCertificate(
    String kid,
    int caId,
    String templateId,
    String subjectName,
  ) async {
    // Шаг 1: Создаём запрос на сертификат (ключ создаётся на сервере)
    final certificate = await CpKeyPlugin.cert.getCert(
      GetCertRequest(
        kid: kid,
        caId: caId,
        tId: templateId,
        dn: {nameKey: subjectName, nameCountry: "RU"},
      ),
    );

    // Шаг 2: Проверяем результат
    if (certificate.type == CertType.Crt.name &&
        (certificate.state == CertState.ACTIVE.name ||
            certificate.state == CertState.OUT_OF_ORDER.name)) {
      return;
    }

    // Шаг 3: Если запрос ушёл в обработку — ждём
    if (certificate.type == CertType.Req.name &&
        certificate.state == CertState.PENDING.name) {
      await _waitForCertificateIssuance(certificate, isClient: false);
    }
  }

  // ========================
  // MOBILE (ключ на мобильном устройстве)
  // ========================

  Future<void> _issueMobileCertificate(
    String kid,
    int caId,
    String templateId,
    String subjectName,
    DSSCryptoKeyContainerType storageType,
  ) async {
    // Шаг 1: Создаём неподписанный запрос на сертификат
    final request = await CpKeyPlugin.cert.getClientCert(
      GetCertRequest(
        kid: kid,
        caId: caId,
        tId: templateId,
        dn: {nameKey: subjectName, nameCountry: "RU"},
      ),
    );

    // Шаг 2: Запрос должен перейти в состояние SIGN_WAIT
    if (request.type != CertType.Req.name ||
        request.state != CertState.SIGN_WAIT.name) {
      throw Exception('Неожиданное состояние запроса: ${request.state}');
    }

    // Шаг 3: Создаём ключ подписи на устройстве и подписываем запрос
    final result = await _createKeyAndSignSeparately(kid, request, storageType);

    await _waitForCertificateIssuance(result, isClient: true);
  }

  /// Раздельное создание ключа и отправка (устойчиво к таймаутам)
  Future<DSSCertificate> _createKeyAndSignSeparately(
    String kid,
    DSSCertificate request,
    DSSCryptoKeyContainerType storageType,
  ) async {
    // Шаг A: Создаём ключ и подписываем запрос локально
    final signResult = await CpKeyPlugin.cert.signRequest(
      SignRequestRequest(
        kid: kid,
        certificate: request,
        providerInfo: CryptoProviderInfo(
          containerName: "",
          provType: 80,
          isExportable: 0,
          savePin: false,
          keyContainerType: storageType,
        ),
      ),
    );
    return signResult.certificate!;
    /* final result = await CpKeyPlugin.cert.sendSignRequest(
      SendSignRequestRequest(
        kid: kid,
        certificate: signResult.certificate,
        signCertRequest: signResult.signedRequest,
        caId: request.caId,
        rid: request.rid,
      ),
    );
    return result;*/
  }

  /// Ожидание выпуска сертификата (polling)
  Future<void> _waitForCertificateIssuance(
    DSSCertificate request, {
    required bool isClient,
  }) async {
    const maxAttempts = 60;
    const pollInterval = Duration(seconds: 5);

    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(pollInterval);

      final certList = await CpKeyPlugin.cert.getCertList(activeUser!.kid!);

      // Ищем наш запрос в списке
      final currentRequest = certList.firstWhereOrNull(
        (c) => c.type == CertType.Req.name && c.rid == request.rid,
      );

      if (currentRequest == null) {
        throw Exception('Запрос на сертификат не найден');
      }

      // Проверяем, перешёл ли запрос в ACCEPTED
      if (currentRequest.state == CertState.ACCEPTED.name) {
        if (isClient) {
          await _installCertificateForClientKey(
            activeUser!.kid!,
            currentRequest,
            certList,
          );
        }
        return;
      }

      // Проверяем, не появился ли сразу готовый сертификат
      final issuedCert = certList.firstWhereOrNull(
        (c) => c.type == CertType.Crt.name && c.cid == currentRequest.cid,
      );
      if (issuedCert != null &&
          (issuedCert.state == CertState.ACTIVE.name ||
              issuedCert.state == CertState.OUT_OF_ORDER.name)) {
        if (isClient) {
          await _installCertificateForClientKey(
            activeUser!.kid!,
            currentRequest,
            certList,
          );
        }
        return;
      }
    }

    throw Exception('Таймаут ожидания выпуска сертификата');
  }

  /// Установка (привязка) сертификата к ключу на мобильном устройстве
  Future<void> _installCertificateForClientKey(
    String kid,
    DSSCertificate request,
    List<DSSCertificate> certList,
  ) async {
    // 1. Получаем ID выпущенного сертификата из запроса
    final certId = request.cid;
    if (certId == null) {
      throw Exception('ID сертификата не найден в запросе');
    }

    // 2. Находим выпущенный сертификат в списке
    final issuedCert = certList.firstWhere(
      (c) => c.type == CertType.Crt.name && c.cid == certId,
      orElse: () => throw Exception('Выпущенный сертификат не найден в списке'),
    );

    // 2. Находим выпущенный сертификат в списке
    final reqCert = certList.firstWhere(
      (c) => c.type == CertType.Req.name && c.cid == certId,
      orElse: () => throw Exception('Запрос не найден в списке'),
    );

    // 3. Связываем сертификат с ключом подписи на устройстве
    await CpKeyPlugin.cert.installCertificate(
      InstallCertificateRequest(
        kid: kid,
        certificate: reqCert,
        rid: reqCert.rid,
        crtBytes: issuedCert.content,
      ),
    );
  }
}

abstract class CreateCertsEvent {}

class LoadCertParams extends CreateCertsEvent {}

class Exit extends CreateCertsEvent {}

class SubmitCreateCert extends CreateCertsEvent {
  final int caId;
  final String templateId;
  final String name;
  final KeyStorageType certStorage;

  SubmitCreateCert({
    required this.caId,
    required this.templateId,
    required this.name,
    required this.certStorage,
  });
}

// states
abstract class CreateCertState {}

class CertParamsLoading extends CreateCertState {}

class CertParamsLoaded extends CreateCertState {
  final CreateCertFormData formData;

  CertParamsLoaded({required this.formData});
}

class CertCreating extends CreateCertState {}

class CertCreated extends CreateCertState {}

class CertError extends CreateCertState {
  final String message;

  CertError({required this.message});
}

class ProcessingTemplate {
  final int id;
  final String name;
  final List<int> templates;

  ProcessingTemplate({
    required this.id,
    required this.name,
    this.templates = const [],
  });
}

class CreateCertFormData {
  final List<DssCaPolicy> policies;
  final List<KeyStorageType> certAvailableStorage;

  CreateCertFormData({
    required this.policies,
    required this.certAvailableStorage,
  });
}

enum CertType { Req, Crt }

enum CertState {
  SIGN_WAIT("sign_wait"),
  PENDING("pending"),
  REGISTRATION("registration"),
  ACCEPTED("accepted"),
  ACTIVE("active"),
  OUT_OF_ORDER("out_of_order");

  final String name;

  const CertState([String? name]) : name = name ?? '';
}

enum KeyStorageType { cloud, mobile, distributed }

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/crypto_pro_dss_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/ru/cryptopro/cpkey/generated/CryptoProDssApi.g.kt',
    swiftOut: 'ios/cpkey/Sources/cpkey/generated/CryptoProDssApi.g.swift',
  ),
)
/// Объединённый enum — супермножество iOS + Android
enum SdkInitCode {
  initOk,
  initCertsNotInstalled,
  initLockScreenNotInstalled,
  initDeviceRooted,

  /// Только Android
  initDeviceHasSpyPrograms,
  initCspNotInitialized,
  initRootCertNotInitializedWrongHash,
  initRootCertNotInitializedWrongSign,
  initRootCertNotInitializedWrongASNTag,
}

class SdkInitRequest {
  /// Подписанный список корневых сертификатов (только Android, iOS проигнорирует)
  Uint8List? rootCertsCmsSignature;
}

class SdkInitResult {
  // Конструктор удален. Pigeon сгенерирует его автоматически.
  SdkInitCode? code;
  String? errorMessage;
}

@HostApi()
abstract class CryptoProDssHostApi {
  /// Инициализация SDK
  /// Android: context берётся нативно
  /// iOS: вызывает SDKFramework.shared._init()
  @async
  SdkInitResult sdkInit(SdkInitRequest request);

  @async
  bool initBioRng();
}

//=============Auth API===============

enum DSSAuthKeyType { dssSdk, cryptoKey }

class DssUser {
  // Конструктор удален. Pigeon сгенерирует его автоматически.

  /// Идентификатор набора ключей пользователя
  String? kid;

  /// Идентификатор пользователя
  String? uid;

  /// Псевдоним набора ключей
  String? alias;

  /// Статус ключа аутентификации
  String? state;

  /// Профиль пользователя в виде сериализованного json-объекта
  String? profile;

  /// Время начала действия ключа аутентификации пользователя (Unix time / Long)
  int? notBefore;

  /// Время окончания действия ключа аутентификации пользователя (Unix time / Long)
  int? notAfter;

  /// Адрес Сервиса взаимодействия с мобильным приложением
  String? serviceUrl;

  /// Дружественное имя учетной записи
  String? name;

  /// Использование ключей: 1 - распределенные ключи, 0 - остальные
  int? authKeyType;

  /// Флаг, указывающий, требуется ли действие для завершения привязки устройства
  bool? isSignatureRequired;

  /// Время создания пароля (Unix time)
  int? passwordCreatedTime;

  /// Время истечения срока действия пароля (Unix time)
  int? passwordExpirationTime;
}

enum DSSProtectionType { password, noProtection, biometric }

enum DSSDeviceType { android, huawei }

class DSSRegisterInfo {
  String? pushAddress;
  String? appVersion;
  String? userName;
  String? phone;
  String? email;
  String? token;
  String? deviceName;
  String? userLogin;

  /// Тип устройства (используется на Android, по умолчанию android)
  DSSDeviceType? deviceType;
}

class QrData {
  String? kid;
  String? uid;
  String? name;
  String? serviceUrl;
  bool? isActivationRequired;
  bool? weakness;
  DSSAuthKeyType? authKeyType;
  String? deeplink;
}

class RawQr {
  String? type;
  int? version;
  QrData? data;

  /// Поле url возвращается на iOS в кортеже отдельно от qrData
  String? url;
}

class ScanQrResult {
  /// Флаг отмены операции пользователем (актуально для Android OperationCancel)
  bool? isCancelled;

  /// Данные QR-кода (присутствуют, если операция не была отменена)
  RawQr? qr;
}

// Класс-контейнер для аргументов, чтобы передавать их структурированно
class RemoveAuthRequest {
  final String kid;
  final String deletedKid;
  final bool forceDelete;

  // Параметры, специфичные для iOS (на Android будут игнорироваться)
  final bool? onlyLocal;
  final bool? silent;

  const RemoveAuthRequest({
    required this.kid,
    required this.deletedKid,
    required this.forceDelete,
    this.onlyLocal,
    this.silent,
  });
}

@HostApi()
abstract class AuthHostApi {
  /// Получение сведений о зарегистрированных пользователях и их устройствах
  @async
  List<DssUser> getAuthList();

  /// Сканирование QR-кода.
  ///
  /// На Android вызывает `scanQr` (передается опциональный base64Qr).
  /// На iOS вызывает `scanAndAddQR` (параметр base64Qr будет проигнорирован).
  @async
  ScanQrResult scanQr(String? base64Qr);

  /// Создает неподтвержденное мобильное устройство (без привязки) в КриптоПро Ключ.
  /// Возвращает device.kid (идентификатор набора ключей).
  @async
  String kinit(
    DssUser dssUser,
    DSSRegisterInfo registerInfo,
    DSSProtectionType keyProtectionType,
    String? activationCode,
    String? password,
  );

  /// Подтверждает установку векторов аутентификации.
  /// Данный метод всегда необходимо вызывать после выполнения регистрации
  /// нового неподтвержденного мобильного устройства в КриптоПро Ключ.
  @async
  void confirm(String kid);

  /// Подтверждает привязку мобильного устройства к учетной записи пользователя.
  /// Данный метод может быть вызван только для векторов аутентификации,
  /// находящихся в состоянии NotVerified.
  @async
  void verifyDevice(String kid, bool silent);

  /// Удаление устройства пользователя и его вектора аутентификации.
  @async
  void removeAuth(RemoveAuthRequest request);
}

//=============Policy API===============

class DssKeyProtectionFlags {
  bool? fingerprintRequired;
  bool? collectEvents;
  bool? collectDeviceInfo;
  bool? collectSimInfo;
  bool? collectLocation;
  int? passwordPolicy;
  bool? denyOSProtection;
  bool? scoringEnabled;
  bool? strongKeyProtectionType;
}

class DssPolicyPayload {
  bool? selfRegistrationEnabled;
  bool? externalLoginRequired;
  bool? keyActivationRequired;
  DssKeyProtectionFlags? keyProtectionFlags;
  List<String?>? keyActivationTypes;
  bool? clientSideSignatureEnabled;
  bool? clientSignEnrollmentEnabled;
  bool? isExternalCertificatesSupported;
  bool? isCryptoKeySdkAuthSupported;
  bool? isDssSdkAuthSupported;
  bool? localDocumentView;
  int? activationCodeLength;
  bool? isRegistrationByCertificateSupported;
  bool? isImportPfxEnabled;
}

/// Запрос на получение списка операций
class GetOperationsRequest {
  /// Идентификатор набора ключей пользователя (iOS, Android)
  final String kid;

  /// Тип операции (iOS, Android)
  final String? type;

  /// Идентификатор операции (iOS, Android)
  final String? opId;

  /// Идентификатор прикладной системы на сервере (iOS, Android)
  final String? clientId;

  const GetOperationsRequest({
    required this.kid,
    this.type,
    this.opId,
    this.clientId,
  });
}

/// Идентификатор прикладной системы (Только на Android, на iOS будет null)
class DssAppSystemDescription {
  final String clientId;
  final String? title;
  final String? description;

  const DssAppSystemDescription({
    required this.clientId,
    this.title,
    this.description,
  });
}

/// Описание операции
class DssOperationDescription {
  /// Тип операции
  final String type;

  /// Краткое описание операции (сериализованный JSON-объект)
  final String? caption;

  /// Развернутое описание операции
  final String? description;

  const DssOperationDescription({
    required this.type,
    this.caption,
    this.description,
  });
}

/// Сведения о документе
class DssDocument {
  /// Идентификатор документа в Сервисе Обработки Документов
  final String id;

  /// Имя документа
  final String title;

  /// Хэш-значение от документа
  final String hash;

  /// Краткая информация о документе (html)
  final String? snippet;

  /// Хэш-значение от краткой информации о документе
  final String? snippetHash;

  /// Размер документа в байтах
  final int fileSize;

  /// Количество страниц в документе
  final int pageCount;

  /// Флаг доступности печатной формы документа
  final bool isPrintableViewAvailable;

  /// Флаг доступности краткой информации о документе
  final bool isSnippetViewAvailable;

  /// Флаг доступности полной PDF-версии документа
  final bool isRawViewAvailable;

  /// Порядковый номер документа в списке (Только iOS)
  final int? order;

  /// Содержимое файла в виде массива байт (используется для офлайн-подписи, только Android)
  final Uint8List? fileBytes;

  const DssDocument({
    required this.id,
    required this.title,
    required this.hash,
    this.snippet,
    this.snippetHash,
    required this.fileSize,
    required this.pageCount,
    required this.isPrintableViewAvailable,
    required this.isSnippetViewAvailable,
    required this.isRawViewAvailable,
    this.order,
    this.fileBytes,
  });
}

class DssOperationParameters {
  final String? encryptionType;
  final String? useFssScenario;
  final String? signatureType;
  final String? isDetached;

  const DssOperationParameters({
    this.encryptionType,
    this.useFssScenario,
    this.signatureType,
    this.isDetached,
  });
}

/// Сведения об операции
class DssOperation {
  /// Описание операции
  final DssOperationDescription description;

  /// Дата создания операции (Unix-time)
  final int createdAt;

  /// Дата истечения операции (Unix-time)
  final int expiresAt;

  /// Срок жизни операции в секундах (Только Android, на iOS может быть null)
  final int? expiresIn;

  /// Количество документов в операции
  final int documentCount;

  /// Идентификатор транзакции
  final String? transactionId;

  /// Словарь дополнительных параметров операции
  final DssOperationParameters? parameters;

  /// Массив сведений о документах в операции
  final List<DssDocument?> documents;

  /// Идентификатор набора ключей (Только iOS, на Android может быть null)
  final String? kid;

  /// Флаг, указывающий, что сертификат и закрытый ключ находятся на мобильном устройстве
  final bool isClientSide;

  /// True - для подписи документа, False - для подписи хэш-значения
  final bool isFullDocRequired;

  /// Идентификатор сертификата, используемого для подписи
  final String? certificateId;

  /// Идентификатор прикладной системы, создавшей операцию (Только Android)
  final DssAppSystemDescription? appSystemInfo;

  /// Возможность выбора режима частичной подписи документов
  final String documentSelectionMode;

  /// Режим отображения по умолчанию печатной формы документа
  final bool? isInstantDocumentView;

  /// Требовать отображения документа средствами ОС на мобильном устройстве
  final bool? isLocalDocumentView;

  /// Версия протокола DSK (Только Android)
  final int? dskProtocolVersion;

  /// Сертификат для подписи тикетов (Только Android)
  final String? dskTicketSigningCert;

  const DssOperation({
    required this.description,
    required this.createdAt,
    required this.expiresAt,
    this.expiresIn,
    required this.documentCount,
    this.transactionId,
    this.parameters,
    required this.documents,
    this.kid,
    required this.isClientSide,
    required this.isFullDocRequired,
    this.certificateId,
    this.appSystemInfo,
    required this.documentSelectionMode,
    this.isInstantDocumentView,
    this.isLocalDocumentView,
    this.dskProtocolVersion,
    this.dskTicketSigningCert,
  });
}

/// Список операций для подтверждения
class DssOperationsInfo {
  /// Массив сведений об операциях
  final List<DssOperation?> operations;

  /// Идентификатор набора ключей пользователя (Только iOS, на Android может быть null)
  final String? kid;

  const DssOperationsInfo({
    required this.operations,
    this.kid,
  });
}

/// Сведения о криптопровайдере
class DssCryptoProviderInfo {
  DssCryptoProviderInfo({
    required this.provType,
    required this.provName,
    this.priority,
    this.containerName,
  });

  /// Тип криптопровайдера
  int provType;

  /// Имя криптопровайдера
  String provName;

  /// Приоритет криптопровайдера (Android)
  int? priority;

  /// Имя ключевого контейнера (iOS)
  String? containerName;
}

/// Политика расширений
class DssExtensionsPolicy {
  DssExtensionsPolicy({
    required this.oid,
    required this.value,
    required this.critical,
  });

  /// Объектный идентификатор расширения
  String oid;

  /// Значение расширения
  String value;

  /// Флаг, указывающий, является ли данное расширение критичным
  bool critical;
}

/// Политика имени пользователя
class DssNamePolicy {
  DssNamePolicy({
    required this.isRequired,
    required this.order,
    required this.oid,
    required this.name,
    this.value,
    required this.stringIdentifier,
  });

  /// Требуется ли обязательно заполнять данный компонент имени
  bool isRequired;

  /// Порядковый номер в списке компонентов имени
  int order;

  /// Объектный идентификатор компонента имени
  String oid;

  /// Отображаемое имя компонента имени
  String name;

  /// Значение компонента имени
  String? value;

  /// Строковый идентификатор компонента имени
  String stringIdentifier;
}

/// Сведения о шаблоне подписи
class DssProcessingTemplate {
  DssProcessingTemplate({
    required this.id,
    required this.description,
  });

  /// Идентификатор шаблона подписи
  int id;

  /// Описание шаблона подписи
  String description;
}

/// Политика обработки запросов на сертификат
class DssCaPolicy {
  DssCaPolicy({
    required this.id,
    this.name,
    required this.active,
    required this.allowUserMode,
    required this.snChangesEnable,
    required this.namePolicy,
    this.caType,
    this.validationMode,
    this.showInUI,
    this.extensionsPolicy,
    this.ekuTemplates,
    this.cryptoProviderInfos,
    this.supportedFlows,
    this.mdipServiceAddress,
    this.mdipPreferedEnrollId,
  });

  /// Идентификатор обработчика запросов на сертификат
  int id;

  /// Отображаемое имя обработчика запросов на сертификат
  String? name;

  /// Доступен ли УЦ для создания запросов
  bool active;

  /// Разрешить подпись запросов на сертификат действующим ключом Пользователя
  bool allowUserMode;

  /// Разрешить изменять имя субъекта в сертификате
  bool snChangesEnable;

  /// Массив компонентов различительного имени пользователя
  List<DssNamePolicy> namePolicy;

  /// Тип обработчика запросов на сертификат
  /// (CryptoProCA15Enroll, CryptoProCA20Enroll, DSSOutOfBandEnroll)
  String? caType;

  /// Режим получения статуса сертификата
  /// (CertificateAuthority, ChainOnline, ChainOffline, NoCheck, OCSP)
  String? validationMode;

  /// Отображается ли обработчик в веб-интерфейсе (Android)
  bool? showInUI;

  /// Политики расширений
  List<DssExtensionsPolicy>? extensionsPolicy;

  /// Массив шаблонов сертификатов (ключ — имя шаблона, значение — список OID)
  Map<String, Object>? ekuTemplates;

  /// Массив сведений о криптопровайдерах (ключ — тип, значение — список провайдеров)
  Map<String, Object>? cryptoProviderInfos;

  /// Список поддерживаемых сценариев (Goskey, Renew) (Android)
  List<String>? supportedFlows;

  /// Адрес сервиса модуля дистанционной идентификации (Android)
  String? mdipServiceAddress;

  /// Предпочтительный идентификатор обработчика (Android)
  String? mdipPreferedEnrollId;
}

/// Параметры подписи (политика взаимодействия с Сервисом Подписи)
class DssCaParams {
  DssCaParams({
    required this.caPolicies,
    required this.processingTemplates,
    this.isMobileKeysSupported,
    this.isDskKeysSupported,
    this.isServerKeysSupported,
  });

  /// Массив политик обработки запросов на сертификат
  List<DssCaPolicy> caPolicies;

  /// Массив шаблонов подписи
  List<DssProcessingTemplate> processingTemplates;

  /// Разрешено ли создание ключей на мобильном устройстве
  bool? isMobileKeysSupported;

  /// Разрешено ли создание распределённых ключей
  bool? isDskKeysSupported;

  /// Разрешено ли создание распределённых ключей
  bool? isServerKeysSupported;
}

@HostApi()
abstract class PolicyHostApi {
  /// Запрос параметров (политики) сервера DSS
  @async
  DssPolicyPayload getParamsDss(String serviceUrl);

  /// Метод получения списка операций, требующих подтверждения.
  @async
  DssOperationsInfo getOperations(GetOperationsRequest request);

  /// Запрос с сервера параметров подписи
  @async
  DssCaParams getCaParams(String kid);
}

//=============Cert API===============

enum DSSCryptoKeyContainerType {
  unknown,
  cloud,
  device,
  rutoken,
  rutokenPKCS11,
  distributed
}

/// Сведения о криптопровайдере
class CryptoProviderInfo {
  /// Имя ключевого контейнера
  final String containerName;

  /// Полное имя ключевого контейнера (только Android)
  final String? fullContainerName;

  /// Тип криптопровайдера (по умолчанию 80)
  final int provType;

  /// Имя криптопровайдера
  final String? provName;

  /// Тип ключевого контейнера
  final DSSCryptoKeyContainerType keyContainerType;

  /// Флаг экспортируемости ключа. По умолчанию 0 (неэкспортируемый).
  /// Только Android.
  final int isExportable;

  /// PUK-код внешнего носителя (если ключ будет сохранен на нем).
  /// Только Android.
  final String? puk;

  /// PIN-код внешнего носителя (если ключ будет сохранен на нем).
  /// Только Android.
  final String? pin;

  /// Сохранять PIN-код внешнего носителя на время действия сессии.
  /// По умолчанию false. Только Android.
  final bool savePin;

  const CryptoProviderInfo({
    required this.containerName,
    this.fullContainerName,
    this.provType = 80,
    this.provName,
    required this.keyContainerType,
    this.isExportable = 0,
    this.puk,
    this.pin,
    this.savePin = false,
  });
}


class DSSCertificate {
  /// Тип объекта: 'crt' - сертификат, 'req' - запрос на сертификат
  String? type;

  /// Идентификатор сертификата
  String? cid;

  /// Идентификатор запроса на сертификат
  String? rid;

  /// Содержимое сертификата (Base64 / DER/PEM)
  String? content;

  /// Идентификатор обработчика запросов на сертификат
  int? caId;

  /// Различительное имя пользователя {"OID компонента имени": "Значение компонента имени"}
  Map<String?, String?>? dn;

  /// Имя издателя (УЦ, выпустившего сертификат)
  Map<String, String>? issuer;

  /// Серийный номер сертификата (HEX-строка)
  String? serialNumber;

  /// Дата начала действия сертификата (Timestamp)
  int? notBefore;

  /// Дата окончания действия сертификата (Timestamp)
  int? notAfter;

  /// Статус сертификата или запроса на сертификат
  String? state;

  /// Отображаемое имя сертификата
  String? friendlyName;

  /// Флаг, указывающий, является ли данный сертификат сертификатом по умолчанию
  bool? isDefault;

  /// Флаг, указывающий, хранится ли ключ на устройстве\внешнем носителе
  bool? isClient;

  /// Флаг, указывающий, архивирован ли ключ на сервере (зарезервировано)
  bool? isArchived;

  /// Флаг, указывающий, является ли соответствующий ключ распределенным (только на Android)
  bool? isDistributed;

  /// Флаг, указывающий, заблокирован ли сертификат на сервере (только на Android)
  bool? isLocked;

  /// Список допустимых типов ключевого контейнера
  List<DSSCryptoKeyContainerType?>? allowedStorageTypes;
}

/// Класс, объединяющий параметры удаления сертификата для обеих платформ.
class DeleteCertRequest {
  /// Идентификатор набора ключей пользователя (iOS, Android)
  final String kid;

  /// Идентификатор сертификата (iOS, Android - на Android может быть null)
  final String? cid;

  /// Идентификатор запроса на сертификат (Используется только на Android)
  final String? rid;

  /// ПИН-код ключевого контейнера (Используется только на iOS)
  final String? pinCode;

  /// Требуется ли удалить сертификат с токена (Используется только на iOS)
  final bool removeFromToken;

  /// Флаг для скрытия/отображения диалоговых окон SDK (Используется только на iOS)
  final bool silent;

  const DeleteCertRequest({
    required this.kid,
    this.cid,
    this.rid,
    this.pinCode,
    this.removeFromToken = true,
    this.silent = false,
  });
}

/// Параметры для создания запроса на сертификат (серверный ключ / распределённый)
class GetCertRequest {
  GetCertRequest({
    required this.kid,
    required this.caId,
    required this.tId,
    required this.dn,
    this.reqParams,
    this.silent,
  });

  /// Идентификатор набора ключей пользователя
  final String kid;

  /// Идентификатор обработчика УЦ
  final int caId;

  /// Идентификатор шаблона сертификата
  final String tId;

  /// Различительное имя субъекта: {"OID компонента имени": "Значение компонента имени"}
  final Map<String, String> dn;

  /// Дополнительные параметры запроса на сертификат (iOS: reqParams)
  final Map<String, String>? reqParams;

  /// Флаг для скрытия/отображения диалоговых окон SDK (iOS only, silent mode)
  final bool? silent;
}

/// Учётные данные для криптопровайдера (внешний носитель)
/// iOS: DSSCryptoProviderInfoCreds
class CryptoProviderCreds {
  CryptoProviderCreds({
    this.pin,
    this.puk,
    this.isSilent,
  });

  /// ПИН-код внешнего носителя / ПИН-код на контейнер сертификата
  final String? pin;

  /// Код инициализации внешнего носителя
  final String? puk;

  /// Доступность ввода учетных данных в silent-режиме (True — только для УНЭП)
  final bool? isSilent;
}

/// Параметры для подписания запроса на сертификат
class SignRequestRequest {
  SignRequestRequest({
    required this.kid,
    required this.certificate,
    this.providerInfo,
    this.creds,
    this.silent,
  });

  /// Идентификатор набора ключей пользователя
  final String kid;

  /// Сведения о созданном неподписанном запросе на сертификат
  final DSSCertificate certificate;

  /// Сведения о криптопровайдере
  final CryptoProviderInfo? providerInfo;

  /// Учётные данные для криптопровайдера (pin, puk, isSilent)
  /// Android: pin передаётся отдельно; iOS: DSSCryptoProviderInfoCreds
  final CryptoProviderCreds? creds;

  /// Флаг для скрытия/отображения диалоговых окон SDK (silent mode).
  /// Используется только для создания УНЭП. Не используется по умолчанию.
  final bool? silent;
}

/// Результат подписания запроса на сертификат
class SignRequestResult {
  SignRequestResult({
    this.certificate,
    this.signedRequest,
  });

  /// Сведения о созданном запросе на сертификат или сертификате.
  /// Заполняется на Android (signRequest отправляет подписанный запрос на сервер).
  final DSSCertificate? certificate;

  /// Подписанный запрос на сертификат, закодированный в Base64.
  /// Заполняется на iOS (signRequest НЕ отправляет на сервер).
  final String? signedRequest;
}

/// Параметры для отправки подписанного запроса на сертификат на сервер
class SendSignRequestRequest {
  SendSignRequestRequest({
    required this.kid,
    this.certificate,
    this.signCertRequest,
    this.creds,
    this.providerInfo,
    this.caId,
    this.rid,
    this.silent,
  });

  /// Идентификатор набора ключей пользователя
  final String kid;

  /// Сведения о запросе на сертификат (Android)
  final DSSCertificate? certificate;

  /// Подписанный запрос на сертификат, закодированный в Base64
  /// Android: signCertRequest (ByteArray?)
  /// iOS: content (Data)
  final String? signCertRequest;

  /// Учётные данные (pin на ключевой контейнер) (Android)
  final CryptoProviderCreds? creds;

  /// Сведения о криптопровайдере (Android)
  final CryptoProviderInfo? providerInfo;

  /// Идентификатор обработчика УЦ (iOS)
  final int? caId;

  /// Идентификатор запроса на сертификат (iOS)
  final String? rid;

  /// Флаг для скрытия/отображения диалоговых окон SDK (iOS: silent mode).
  /// Не используется по умолчанию.
  final bool? silent;
}

/// Параметры для установки сертификата в ключевой контейнер
class InstallCertificateRequest {
  InstallCertificateRequest({
    required this.certificate,
    this.kid,
    this.rid,
    this.crtBytes,
    this.creds,
  });

  /// Сведения о сертификате / запросе на сертификат, который требуется установить
  /// Android: certificate (Certificate) — сведения о запросе
  /// iOS: cert (DSSCertificate) — сведения и содержимое сертификата
  final DSSCertificate certificate;

  /// Идентификатор набора ключей пользователя (iOS)
  final String? kid;

  /// Идентификатор запроса на сертификат (iOS)
  final String? rid;

  /// Сертификат, который требуется установить, закодированный в Base64 (Android: crtBytes)
  final String? crtBytes;

  /// Учётные данные (pin на контейнер закрытого ключа)
  /// Android: pin; iOS: DSSCryptoProviderInfoCreds (pin, puk, isSilent)
  final CryptoProviderCreds? creds;
}

@HostApi()
abstract class CertHostApi {
  /// Получение списка запросов на сертификаты и списка сертификатов пользователя.
  @async
  List<DSSCertificate> getCertList(String kid);

  /// Метод удаления сертификата.
  @async
  void deleteCert(DeleteCertRequest request);

  /// Создание запроса на сертификат с ключом на сервере (cloud / distributed)
  /// Android: Cert.getCert(...)
  /// iOS: createUnsignedCert(...)
  @async
  DSSCertificate getCert(GetCertRequest request);

  /// Создание неподписанного запроса на сертификат и отправка его на сервер для синхронизации.
  /// Android: getClientCert(context, kid, caId, tId, dn, callback)
  /// iOS: createUnsignedCert(kid, caId, tId, dn, reqParams, silent)
  @async
  DSSCertificate getClientCert(GetCertRequest request);

  /// Создание ключа подписи на мобильном устройстве или внешнем носителе
  /// и подписание запроса на сертификат.
  ///
  /// Android: создаёт ключ, подписывает запрос и отправляет на сервер → возвращает Certificate.
  /// iOS: создаёт ключ и подписывает запрос БЕЗ отправки на сервер → возвращает signedRequest (Base64).
  @async
  SignRequestResult signRequest(SignRequestRequest request);

  /// Отправка подписанного запроса на сертификат на сервер для синхронизации.
  /// Android: sendSignRequest(context, kid, certificate, signCertRequest, pin, providerInfo, callback)
  /// iOS: sendClientSignedCertificate(kid, caId, rid, content, silent)
  @async
  DSSCertificate sendSignRequest(SendSignRequestRequest request);

  /// Установка сертификата в ключевой контейнер на мобильном устройстве
  /// или внешнем носителе.
  /// Android: также отправляет сертификат на сервер для синхронизации.
  /// iOS: только локальная установка без отправки.
  ///
  /// Android: installCertificate(context, certificate, crtBytes, pin, callback)
  /// iOS: installCertificate(kid, cert, rid, cred)
  @async
  void installCertificate(InstallCertificateRequest request);
}

//=============Sign API===============

/// Режим отправки подтверждения операции
enum DssConfirmationSendingMode {
  /// Сформированный запрос с подтверждением SDK сразу отправляет на сервер
  online,

  /// Приложение сохраняет запрос для возможности отправить его позднее
  offline,
}

/// Результат подтверждения операции
enum DssConfirmState {
  /// Неизвестно
  unknown,

  /// Подтверждено
  confirmed,

  /// Отклонено
  declined,
}

/// Тип результата операции signMT
enum DssSignMtResultType {
  /// Полное подтверждение всех документов
  success,

  /// Частичное подтверждение (некоторые документы не подтверждены)
  partialSuccess,

  /// Отложенное подписание
  suspendedConfirm,
}

/// Сведения о подтверждённом документе
class DssConfirmedDocument {
  /// Идентификатор документа
  final String id;

  /// Хэш-значение от документа
  final String hash;

  const DssConfirmedDocument({
    required this.id,
    required this.hash,
  });
}

/// Сведения об отклонённом документе
class DssDeclinedDocument {
  /// Идентификатор документа
  final String id;

  /// Хэш-значение от документа
  final String hash;

  const DssDeclinedDocument({
    required this.id,
    required this.hash,
  });
}

/// Сведения о подтверждаемой операции
class DssApprovedOperation {
  /// Идентификатор операции на Сервисе Операций
  final String id;

  /// Тип операции
  final String type;

  /// Описание операции
  final String caption;

  /// Дополнительные параметры операции
  final Map<String?, String?>? parameters;

  /// Массив сведений о подтвержденных документах
  final List<DssConfirmedDocument?>? confirmedDocuments;

  /// Массив сведений об отклоненных документах
  final List<DssDeclinedDocument?>? declinedDocuments;

  /// Штамп времени
  final int timeStamp;

  const DssApprovedOperation({
    required this.id,
    required this.type,
    required this.caption,
    this.parameters,
    this.confirmedDocuments,
    this.declinedDocuments,
    required this.timeStamp,
  });
}

/// Запрос на подтверждение/отклонение операции, созданной на сервере
class DssApproveRequestMt {
  /// Сведения о подтверждаемой операции
  final DssApprovedOperation approvedOperation;

  /// Код аутентификации операции (HMAC)
  final String hmac;

  const DssApproveRequestMt({
    required this.approvedOperation,
    required this.hmac,
  });
}

/// Результат выполнения операции signMT
class DssSignMtResult {
  /// Тип результата
  final DssSignMtResultType resultType;

  /// Результат подтверждения операции (для success и partialSuccess)
  final DssConfirmState? confirmState;

  /// Запрос на подтверждение/отклонение (для отложенного подписания - suspendedConfirm)
  final DssApproveRequestMt? approveRequest;

  /// Список документов с ошибками (для partialSuccess)
  final List<DssDocument?>? documentsWithErrors;

  /// Сведения об ошибках: ключ - id документа, значение - описание ошибки (Только iOS)
  final Map<String?, String?>? documentErrors;

  const DssSignMtResult({
    required this.resultType,
    this.confirmState,
    this.approveRequest,
    this.documentsWithErrors,
    this.documentErrors,
  });
}

@HostApi()
abstract class SignHostApi {

  /// Подтверждение операции, созданной на сервере
  ///
  /// [kid] - Идентификатор набора ключей пользователя
  /// [operation] - Сведения об операции
  /// [enableMultiSelection] - Флаг, разрешено ли частичное подписание
  /// [confirmationSendingMode] - Режим отправки подтверждения (online/offline)
  /// [pinCode] - ПИН-код на ключевой контейнер (опционально)
  /// [silent] - Флаг для скрытия/отображения диалоговых окон SDK
  @async
  DssSignMtResult signMt(
      String kid,
      DssOperation? operation,
      bool enableMultiSelection,
      DssConfirmationSendingMode confirmationSendingMode,
      String? pinCode,
      bool silent);
}


/// Универсальная модель сведений о ключевом контейнере для обеих платформ
class DSSSigningKeyInfo {
  // --- Общие поля для Android и iOS ---
  final String? uid;
  final String? containerName;
  final String? containerFullName; // fullContainerName на Android / containerFullName на iOS
  final String? cid; // На Android приведем Int к String
  final String? rid; // На Android приведем Int к String
  final bool isInstalled; // isInstall на Android / isInstalled на iOS
  final String? certBase64;
  final DSSCryptoKeyContainerType? keyContainerType; // keyContainerType на Android / providerKeyType на iOS
  final String? pin; // encryptedPin на Android / savedPin на iOS

  // --- Специфичные поля для Android ---
  final CryptoProviderInfo? providerInfo;

  // --- Специфичные поля для iOS ---
  final String? kid;
  final String? providerName;
  final int? providerType;
  final bool? isExportable;

  // Даты передаем в миллисекундах (Unix Timestamp)
  final int? createdAtMs;
  final int? installedAtMs;

  const DSSSigningKeyInfo({
    this.uid,
    this.containerName,
    this.containerFullName,
    this.cid,
    this.rid,
    required this.isInstalled,
    this.certBase64,
    this.keyContainerType,
    this.pin,
    this.providerInfo,
    this.kid,
    this.providerName,
    this.providerType,
    this.isExportable,
    this.createdAtMs,
    this.installedAtMs,
  });
}

@HostApi()
abstract class SigningKeyHostApi {
  /// Получение списка ключей подписи.
  /// [checkAllContainers] используется только на Android (на iOS параметр будет проигнорирован).
  @async
  List<DSSSigningKeyInfo> listKeys(bool checkAllContainers);
}
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

/// Сведения о документе в операции
class DssDocument {
  // Добавьте сюда поля документа, если они необходимы.
  // На данный момент оставляем пустым/базовым для корректной компиляции.
  final String? id;
  final String? name;

  const DssDocument({this.id, this.name});
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

@HostApi()
abstract class PolicyHostApi {
  /// Запрос параметров (политики) сервера DSS
  @async
  DssPolicyPayload getParamsDss(String serviceUrl);

  /// Метод получения списка операций, требующих подтверждения.
  @async
  DssOperationsInfo getOperations(GetOperationsRequest request);
}

//=============Cert API===============

enum DSSCryptoKeyContainerType {
  unknown,
  device,
  rutoken,
  rutokenPKCS11,
  distributed,
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

@HostApi()
abstract class CertHostApi {
  /// Получение списка запросов на сертификаты и списка сертификатов пользователя.
  @async
  List<DSSCertificate> getCertList(String kid);

  /// Метод удаления сертификата.
  @async
  void deleteCert(DeleteCertRequest request);
}

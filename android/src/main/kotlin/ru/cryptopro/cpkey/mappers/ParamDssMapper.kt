package ru.cryptopro.cpkey.mappers

import DssKeyProtectionFlags
import DssPolicyPayload
import ru.cryptopro.cryptokey.presentation.external.policy.model.KeyProtectionFlags
import ru.cryptopro.cryptokey.presentation.external.policy.model.ParamsDss

fun ParamsDss.toPigeonModel(): DssPolicyPayload {
    return DssPolicyPayload(
        selfRegistrationEnabled = this.isSelfRegistrationEnabled,
        externalLoginRequired = this.externalLoginRequired,
        keyActivationRequired = this.isKeyActivationRequired,
        keyProtectionFlags = this.keyProtectionFlags.toPigeonModel(),
        keyActivationTypes = this.keyActivationTypes,
        clientSideSignatureEnabled = this.isClientSideSignatureEnabled,
        clientSignEnrollmentEnabled = this.isClientSignEnrollmentEnabled,
        isExternalCertificatesSupported = null,
        isCryptoKeySdkAuthSupported = this.isCryptoKeySdkAuthSupported,
        isDssSdkAuthSupported = this.isDssSdkAuthSupported,
        localDocumentView = this.localDocumentView,
        activationCodeLength = this.activationCodeLength.toLong(),
        isRegistrationByCertificateSupported = null,
        isImportPfxEnabled = this.isImportPfxEnabled
    )
}

fun KeyProtectionFlags.toPigeonModel(): DssKeyProtectionFlags {
    return DssKeyProtectionFlags(
        fingerprintRequired = this.fingerprintRequired,
        collectEvents = this.collectEvents,
        collectDeviceInfo = this.collectDeviceInfo,
        collectSimInfo = this.collectSimInfo,
        collectLocation = this.collectLocation,
        passwordPolicy = this.passwordPolicy.toLong(),
        denyOSProtection = this.isDenyOSProtection,
        scoringEnabled = this.scoringEnabled,
        strongKeyProtectionType = this.strongKeyProtectionType
    )
}
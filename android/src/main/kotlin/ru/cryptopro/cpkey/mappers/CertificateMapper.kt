package ru.cryptopro.cpkey.mappers

import CryptoProviderInfo
import DSSCertificate
import DSSCryptoKeyContainerType
import FlutterError
import ru.cryptopro.cryptokey.presentation.external.cert.models.Certificate
import ru.cryptopro.cryptokey.presentation.external.cert.models.KeyContainerType
import ru.cryptopro.cryptokey.presentation.external.cert.models.ProviderInfo

fun Certificate.toPigeonModel(): DSSCertificate {
    val mappedStorageTypes = this.getAllowedStorageTypes().map { typeInt ->
        when (typeInt) {
            1 -> DSSCryptoKeyContainerType.DEVICE
            2 -> DSSCryptoKeyContainerType.RUTOKEN
            3 -> DSSCryptoKeyContainerType.DISTRIBUTED
            else -> DSSCryptoKeyContainerType.UNKNOWN
        }
    }

    return DSSCertificate(
        type = this.type ?: "crt",
        cid = if (this.cid == 0) {
            null
        } else this.cid.toString(), // Приводим Int к String для унификации с iOS
        rid = if (this.rid == 0) {
            null
        } else this.rid.toString(), // Приводим Int к String для унификации с iOS
        content = this.content ?: "",
        caId = this.caId.toLong(),
        dn = this.dn as Map<String?, String?>?,
        issuer = this.issuer,
        serialNumber = this.serialNumber ?: "",
        notBefore = this.notBefore, // В Android это Long, в Pigeon сгенерируется как Long
        notAfter = this.notAfter,
        state = this.state ?: "",
        friendlyName = this.friendlyName,
        isDefault = this.isDefault,
        isClient = this.isClient,
        isArchived = this.isArchived,
        isDistributed = this.isDistributed,
        isLocked = this.isLocked,
        allowedStorageTypes = mappedStorageTypes
    )
}

fun CryptoProviderInfo.toNative(): ProviderInfo {
    return ProviderInfo(
        containerName = containerName,
        fullContainerName = fullContainerName,
        provType = provType.toInt(),
        provName = provName,
        keyContainerType = keyContainerType.mapKeyContainerTypeToNative(),
        isExportable = isExportable.toInt(),
        puk = puk,
        pin = pin ?: "",
        savePin = savePin,
    )
}

private fun DSSCryptoKeyContainerType.mapKeyContainerTypeToNative(): KeyContainerType {
    return when (this) {
        DSSCryptoKeyContainerType.DEVICE -> KeyContainerType.DEVICE
        DSSCryptoKeyContainerType.RUTOKEN -> KeyContainerType.TOKEN_FKN
        DSSCryptoKeyContainerType.RUTOKEN_PKCS11 -> KeyContainerType.TOKEN_PKCS11
        DSSCryptoKeyContainerType.DISTRIBUTED -> KeyContainerType.DISTRIBUTED
        else -> {
            throw FlutterError("Unknown key container type")
        }
    }
}
package ru.cryptopro.cpkey.mappers

import CryptoProviderInfo
import DSSCryptoKeyContainerType
import DSSSigningKeyInfo
import FlutterError
import ru.cryptopro.cryptokey.presentation.external.cert.models.KeyContainerType
import ru.cryptopro.cryptokey.presentation.external.cert.models.ProviderInfo
import ru.cryptopro.cryptokey.presentation.external.sign.models.SigningKeyInfo

fun SigningKeyInfo.toPigeon(): DSSSigningKeyInfo {
    return DSSSigningKeyInfo(
        uid = uid,
        containerName = containerName,
        containerFullName = fullContainerName,
        // Конвертируем Int в String, как договорились в контракте Pigeon
        cid = cid.toString(),
        rid = rid.toString(),
        // На Android поле называется isInstall, в Pigeon — isInstalled
        isInstalled = isInstall,
        certBase64 = certBase64,
        keyContainerType = keyContainerType?.mapKeyContainerTypeToPigeon(),
        pin = encryptedPin,
        providerInfo = providerInfo?.toPigeon(),

        // Поля ниже специфичны для iOS, на Android мы передаем null
        kid = null,
        providerName = null,
        providerType = null,
        isExportable = null,
        createdAtMs = null,
        installedAtMs = null
    )
}


fun ProviderInfo.toPigeon(): CryptoProviderInfo {
    return CryptoProviderInfo(
        containerName = containerName,
        fullContainerName = fullContainerName,
        provType = provType.toLong(),
        provName = provName,
        keyContainerType = keyContainerType!!.mapKeyContainerTypeToPigeon(),
        isExportable = isExportable.toLong(),
        puk = puk,
        pin = pin ?: "",
        savePin = savePin,
    )
}

private fun KeyContainerType.mapKeyContainerTypeToPigeon(): DSSCryptoKeyContainerType {
    return when (this) {
        KeyContainerType.DEVICE -> DSSCryptoKeyContainerType.DEVICE
        KeyContainerType.TOKEN_FKN -> DSSCryptoKeyContainerType.RUTOKEN
        KeyContainerType.TOKEN_PKCS11 -> DSSCryptoKeyContainerType.RUTOKEN_PKCS11
        KeyContainerType.DISTRIBUTED -> DSSCryptoKeyContainerType.DISTRIBUTED
        else -> {
            throw FlutterError("Unknown key container type")
        }
    }
}
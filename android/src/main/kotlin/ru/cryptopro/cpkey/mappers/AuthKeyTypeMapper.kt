package ru.cryptopro.cpkey.mappers

import DSSAuthKeyType
import ru.cryptopro.cryptokey.presentation.external.auth.models.AuthKeyType

fun AuthKeyType.toPigeonModel(): DSSAuthKeyType {
    return when (this) {
        AuthKeyType.AUTH_KEY_DSS_SDK -> DSSAuthKeyType.DSS_SDK
        AuthKeyType.AUTH_KEY_CRYPTO -> DSSAuthKeyType.CRYPTO_KEY
    }
}

fun Int.toPigeonModel(): DSSAuthKeyType {
    return when (this) {
        AuthKeyType.AUTH_KEY_DSS_SDK.codeType -> DSSAuthKeyType.DSS_SDK
        AuthKeyType.AUTH_KEY_CRYPTO.codeType -> DSSAuthKeyType.CRYPTO_KEY
        else -> throw Exception("Unknown auth key type")
    }
}
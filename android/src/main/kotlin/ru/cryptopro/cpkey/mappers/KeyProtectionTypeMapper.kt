package ru.cryptopro.cpkey.mappers

import DSSProtectionType
import ru.cryptopro.cryptokey.presentation.external.auth.models.KeyProtectionType

fun DSSProtectionType.toNativeModel(): KeyProtectionType {
    return when (this) {
        DSSProtectionType.PASSWORD -> KeyProtectionType.PASSWORD
        DSSProtectionType.NO_PROTECTION -> KeyProtectionType.NO_PROTECTION
        DSSProtectionType.BIOMETRIC -> KeyProtectionType.BIOMETRIC
    }
}
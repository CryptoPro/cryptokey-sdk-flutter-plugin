package ru.cryptopro.cpkey.mappers

import DSSCertificate
import ru.cryptopro.cryptokey.presentation.external.cert.models.Certificate

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
        cid = this.cid.toString(), // Приводим Int к String для унификации с iOS
        rid = this.rid.toString(), // Приводим Int к String для унификации с iOS
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
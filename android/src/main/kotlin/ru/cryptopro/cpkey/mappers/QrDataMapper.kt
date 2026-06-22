package ru.cryptopro.cpkey.mappers

import QrData
import RawQr
import ru.cryptopro.cryptokey.presentation.external.auth.models.qr.QRData
import ru.cryptopro.cryptokey.presentation.external.auth.models.qr.RawQR

fun RawQR.toPigeonModel(): RawQr {
    return RawQr(
        type = this.type,
        version = this.version.toLong(),
        data = this.data?.toPigeonModel(),
        url = this.data?.serviceUrl // На Android url находится внутри QRData (ServiceUrl)
    )
}

fun QRData.toPigeonModel(): QrData {
    return QrData(
        kid = this.kid,
        uid = this.uid,
        name = this.name,
        serviceUrl = this.serviceUrl, // В зависимости от SDK может быть ServiceUrl или serviceUrl
        isActivationRequired = this.isActivationRequired,
        weakness = this.weakness,
        authKeyType = this.authKeyType.toPigeonModel(),
        deeplink = this.deeplink
    )
}
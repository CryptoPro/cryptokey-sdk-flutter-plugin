package ru.cryptopro.cpkey.mappers

import DssUser

fun ru.cryptopro.cryptokey.presentation.external.auth.models.DssUser.mapDssUser(): DssUser {
    return DssUser(
        kid = this.kid,
        uid = this.uid,
        state = this.state,
        serviceUrl = this.serviceUrl,
        name = this.name,
        authKeyType = this.authKeyType.toLong(),
        profile = this.profile
    )
}

fun DssUser.toNativeModel(): ru.cryptopro.cryptokey.presentation.external.auth.models.DssUser {
    return ru.cryptopro.cryptokey.presentation.external.auth.models.DssUser(
        serviceUrl = this@toNativeModel.serviceUrl ?: "",
        name = this@toNativeModel.name ?: ""
    )
}
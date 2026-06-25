package ru.cryptopro.cpkey.impl

import DSSSigningKeyInfo
import SigningKeyHostApi
import android.content.Context
import ru.cryptopro.cpkey.mappers.toPigeon
import ru.cryptopro.cryptokey.presentation.external.sign.SigningKey

class SigningKeyHostApiImpl(
    private val context: Context
) : SigningKeyHostApi {

    val signingKey = SigningKey(context)

    override fun listKeys(
        checkAllContainers: Boolean,
        callback: (Result<List<DSSSigningKeyInfo>>) -> Unit
    ) {
        callback.invoke(Result.success(signingKey.listKeys(checkAllContainers).map { it.toPigeon() }))
    }
}
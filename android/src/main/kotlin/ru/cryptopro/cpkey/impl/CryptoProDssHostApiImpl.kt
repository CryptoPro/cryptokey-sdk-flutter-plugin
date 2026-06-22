package ru.cryptopro.cpkey.impl

import CryptoProDssHostApi
import SdkInitRequest
import SdkInitResult
import android.content.Context
import ru.cryptopro.cpkey.mappers.SdkInitMapper
import ru.cryptopro.cryptokey.domain.interfaces.base.SdkCryptoProDssInitCallback
import ru.cryptopro.cryptokey.initialization.CryptoProDss.init
import ru.cryptopro.cryptokey.initialization.CryptoProDss.initBioRng
import ru.cryptopro.cryptokey.initialization.model.CSPInitCode
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultCallback

class CryptoProDssHostApiImpl(
    private val context: Context
) : CryptoProDssHostApi {

    override fun sdkInit(request: SdkInitRequest, callback: (Result<SdkInitResult>) -> Unit) {
        init(context, sdkInitCallback = object : SdkCryptoProDssInitCallback {
            override fun onInitSuccess(initResult: CSPInitCode) {
                val code = SdkInitMapper.mapInitCode(initResult)
                callback(Result.success(SdkInitResult(code = code)))
            }

            override fun onInitFailed(initResult: CSPInitCode) {
                val code = SdkInitMapper.mapInitCode(initResult)
                callback(Result.success(SdkInitResult(code = code)))
            }
        })
    }

    override fun initBioRng(callback: (Result<Boolean>) -> Unit) {
        initBioRng(context, object : SdkResultCallback<Unit> {
            override fun onOperationSuccessful(result: Unit) {
                callback(Result.success(true))
            }

            override fun onOperationFailed(
                errorCode: Int,
                errorString: String?,
                t: Throwable?
            ) {
                callback(Result.success(false))
            }
        })
    }
}
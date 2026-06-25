package ru.cryptopro.cpkey.impl

import DssCaParams
import DssOperationsInfo
import DssPolicyPayload
import FlutterError
import GetOperationsRequest
import PolicyHostApi
import android.content.Context
import ru.cryptopro.cpkey.mappers.toPigeon
import ru.cryptopro.cpkey.mappers.toPigeonModel
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultCallback
import ru.cryptopro.cryptokey.presentation.external.policy.Policy
import ru.cryptopro.cryptokey.presentation.external.policy.model.CaParams
import ru.cryptopro.cryptokey.presentation.external.policy.model.OperationInfo
import ru.cryptopro.cryptokey.presentation.external.policy.model.ParamsDss
import ru.cryptopro.cryptokey.presentation.external.sign.models.OperationsInfo
import kotlin.Result.Companion.failure

class PolicyHostApiImpl(
    private val context: Context
) : PolicyHostApi {

    val policy = Policy()

    override fun getParamsDss(
        serviceUrl: String,
        callback: (Result<DssPolicyPayload>) -> Unit
    ) {
        policy.getParamsDSS(serviceUrl, object : SdkResultCallback<ParamsDss> {
            override fun onOperationSuccessful(result: ParamsDss) {
                callback.invoke(Result.success(result.toPigeonModel()))
            }

            override fun onOperationFailed(
                errorCode: Int,
                errorString: String?,
                t: Throwable?
            ) {
                callback.invoke(failure(t ?: throw FlutterError("get ParamsDSS error")))
            }
        })
    }

    override fun getOperations(
        request: GetOperationsRequest,
        callback: (Result<DssOperationsInfo>) -> Unit
    ) {
        policy.getOperations(
            context,
            request.kid,
            request.type,
            request.opId,
            request.clientId,
            object : SdkResultCallback<OperationsInfo> {

                override fun onOperationFailed(
                    errorCode: Int,
                    errorString: String?,
                    t: Throwable?
                ) {
                    callback.invoke(failure(t ?: throw FlutterError("getOperations failed")))
                }

                override fun onOperationSuccessful(result: OperationsInfo) {
                    callback.invoke(Result.success(result.toPigeon()))
                }

            })
    }

    override fun getCaParams(
        kid: String,
        callback: (Result<DssCaParams>) -> Unit
    ) {
        policy.getCaParams(context, kid, object : SdkResultCallback<CaParams> {
            override fun onOperationSuccessful(result: CaParams) {
                callback.invoke(Result.success(result.toPigeon()))
            }

            override fun onOperationFailed(
                errorCode: Int,
                errorString: String?,
                t: Throwable?
            ) {
                callback.invoke(failure(t ?: FlutterError(" getCaParams failed")))
            }
        })
    }
}
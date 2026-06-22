package ru.cryptopro.cpkey.impl

import CertHostApi
import DSSCertificate
import DeleteCertRequest
import DssPolicyPayload
import PolicyHostApi
import android.content.Context
import ru.cryptopro.cpkey.mappers.toPigeonModel
import ru.cryptopro.cryptokey.presentation.external.cert.Cert
import ru.cryptopro.cryptokey.presentation.external.cert.models.Certificate
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultCallback
import ru.cryptopro.cryptokey.presentation.external.policy.Policy
import ru.cryptopro.cryptokey.presentation.external.policy.model.ParamsDss

class CertHostApiImpl(
    private val context: Context
) : CertHostApi {

    val cert = Cert()

    override fun getCertList(kid: String, callback: (Result<List<DSSCertificate>>) -> Unit) {
        cert.getCertList(context, kid, object : SdkResultCallback<List<Certificate>> {

            override fun onOperationSuccessful(result: List<Certificate>) {
                callback.invoke(Result.success(result.map { it.toPigeonModel() }))
            }

            override fun onOperationFailed(
                errorCode: Int,
                errorString: String?,
                t: Throwable?
            ) {
                callback.invoke(Result.failure(t ?: Exception("get ParamsDSS error")))
            }
        })
    }

    override fun deleteCert(
        request: DeleteCertRequest,
        callback: (Result<Unit>) -> Unit
    ) {
        cert.deleteCert(context, request.kid, request.cid, request.rid, object  : SdkResultCallback<Unit>{
            override fun onOperationSuccessful(result: Unit) {
                callback.invoke(Result.success(Unit))
            }

            override fun onOperationFailed(
                errorCode: Int,
                errorString: String?,
                t: Throwable?
            ) {
                callback.invoke(Result.failure(t ?: Exception("Delete cert error")))
            }
        })
    }
}
package ru.cryptopro.cpkey.impl

import CertHostApi
import DSSCertificate
import DeleteCertRequest
import DssPolicyPayload
import FlutterError
import GetCertRequest
import InstallCertificateRequest
import PolicyHostApi
import SendSignRequestRequest
import SignRequestRequest
import SignRequestResult
import android.content.Context
import android.util.Base64
import android.util.Log
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import ru.cryptopro.cpkey.mappers.toNative
import ru.cryptopro.cpkey.mappers.toPigeonModel
import ru.cryptopro.cryptokey.presentation.external.cert.Cert
import ru.cryptopro.cryptokey.presentation.external.cert.models.Certificate
import ru.cryptopro.cryptokey.presentation.external.exception.CryptoProSdkException
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultCallback
import ru.cryptopro.cryptokey.presentation.external.policy.Policy
import ru.cryptopro.cryptokey.presentation.external.policy.model.ParamsDss
import ru.cryptopro.cryptokey.presentation.external.sign.SigningKey
import ru.cryptopro.cryptokey.presentation.external.sign.models.SigningKeyInfo

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
        cert.deleteCert(
            context,
            request.kid,
            request.cid,
            request.rid,
            object : SdkResultCallback<Unit> {
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

    override fun getCert(
        request: GetCertRequest,
        callback: (Result<DSSCertificate>) -> Unit
    ) {
        cert.getCert(
            context,
            request.kid,
            request.caId.toInt(),
            request.tId,
            request.dn,
            object : SdkResultCallback<Certificate> {
                override fun onOperationSuccessful(result: Certificate) {
                    callback.invoke(Result.success(result.toPigeonModel()))
                }

                override fun onOperationFailed(
                    errorCode: Int,
                    errorString: String?,
                    t: Throwable?
                ) {
                    callback.invoke(Result.failure(t ?: FlutterError("getCert Error")))
                }

            })
    }

    override fun getClientCert(
        request: GetCertRequest,
        callback: (Result<DSSCertificate>) -> Unit
    ) {
        cert.getClientCert(
            context,
            request.kid,
            request.caId.toInt(),
            request.tId,
            request.dn,
            object : SdkResultCallback<Certificate> {
                override fun onOperationSuccessful(result: Certificate) {
                    callback.invoke(Result.success(result.toPigeonModel()))
                }

                override fun onOperationFailed(
                    errorCode: Int,
                    errorString: String?,
                    t: Throwable?
                ) {
                    callback.invoke(Result.failure(t ?: FlutterError("getCert Error")))
                }

            })
    }

    override fun signRequest(
        request: SignRequestRequest,
        callback: (Result<SignRequestResult>) -> Unit
    ) {
        cert.getCertList(context, request.kid, object : SdkResultCallback<List<Certificate>> {

            override fun onOperationSuccessful(result: List<Certificate>) {
                val certificate = result.first { it.rid.toString() == request.certificate.rid }
                cert.signRequest(
                    context,
                    request.kid,
                    null,
                    certificate,
                    request.providerInfo?.toNative(),
                    request.silent ?: false,
                    object : SdkResultCallback<Certificate> {
                        override fun onOperationSuccessful(result: Certificate) {
                            callback.invoke(Result.success(SignRequestResult(result.toPigeonModel())))
                        }

                        override fun onOperationFailed(
                            errorCode: Int,
                            errorString: String?,
                            t: Throwable?
                        ) {
                            callback.invoke(Result.failure(t ?: FlutterError("signRequest Error")))
                        }

                    }
                )
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

    override fun sendSignRequest(
        request: SendSignRequestRequest,
        callback: (Result<DSSCertificate>) -> Unit
    ) {
        cert.getCertList(context, request.kid, object : SdkResultCallback<List<Certificate>> {

            override fun onOperationSuccessful(result: List<Certificate>) {
                val certificate =
                    result.first { it.rid.toString() == request.certificate?.rid || it.cid.toString() == request.certificate?.cid }
                cert.sendSignRequest(
                    context,
                    request.kid,
                    certificate,
                    request.signCertRequest?.toByteArray(),
                    pin = null,
                    request.providerInfo?.toNative()!!,
                    object : SdkResultCallback<Certificate> {
                        override fun onOperationSuccessful(result: Certificate) {
                            callback.invoke(Result.success(result.toPigeonModel()))
                        }

                        override fun onOperationFailed(
                            errorCode: Int,
                            errorString: String?,
                            t: Throwable?
                        ) {
                            callback.invoke(Result.failure(t ?: FlutterError("signRequest Error")))
                        }

                    }
                )
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

    override fun installCertificate(
        request: InstallCertificateRequest,
        callback: (Result<Unit>) -> Unit
    ) {
        cert.getCertList(context, request.kid!!, object : SdkResultCallback<List<Certificate>> {

            override fun onOperationSuccessful(result: List<Certificate>) {
                val certificate =
                    result.first { it.rid.toString() == request.certificate.rid || it.cid.toString() == request.certificate.cid }
                cert.installCertificate(
                    context,
                    certificate,
                    Base64.decode(request.crtBytes, Base64.DEFAULT),
                    "",
                    object : SdkResultCallback<Unit> {

                        override fun onOperationSuccessful(result: Unit) {
                            callback.invoke(Result.success(Unit))
                        }

                        override fun onOperationFailed(
                            errorCode: Int,
                            errorString: String?,
                            t: Throwable?
                        ) {
                            callback.invoke(Result.failure(t ?: FlutterError("signRequest Error")))
                        }
                    }
                )
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
}
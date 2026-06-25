package ru.cryptopro.cpkey.impl

import AuthHostApi
import DSSProtectionType
import DSSRegisterInfo
import DssUser
import FlutterError
import RemoveAuthRequest
import ScanQrResult
import android.content.Context
import ru.cryptopro.cpkey.mappers.mapDssUser
import ru.cryptopro.cpkey.mappers.toNativeModel
import ru.cryptopro.cpkey.mappers.toPigeonModel
import ru.cryptopro.cryptokey.presentation.external.auth.Auth
import ru.cryptopro.cryptokey.presentation.external.auth.models.qr.RawQR
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultCallback
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultType

class AuthHostApiImpl(
    private val context: Context
) : AuthHostApi {

    val auth = Auth()

    override fun getAuthList(callback: (Result<List<DssUser>>) -> Unit) {
        callback.invoke(Result.success(auth.getAuthList(context).map { it.mapDssUser() }))
    }

    override fun scanQr(
        base64Qr: String?,
        callback: (Result<ScanQrResult>) -> Unit
    ) {
        auth.scanQr(
            context = context,
            base64Qr = null,
            callback = object : SdkResultCallback<SdkResultType<RawQR>> {
                override fun onOperationSuccessful(result: SdkResultType<RawQR>) {
                    when (result) {
                        is SdkResultType.OperationCancel<RawQR> -> {
                            callback.invoke(
                                Result.success(
                                    ScanQrResult(
                                        isCancelled = true,
                                        qr = null
                                    )
                                )
                            )
                        }

                        is SdkResultType.OperationSuccess<RawQR> -> {
                            callback.invoke(
                                Result.success(
                                    ScanQrResult(
                                        isCancelled = false,
                                        qr = result.result.toPigeonModel()
                                    )
                                )
                            )
                        }
                    }
                }

                override fun onOperationFailed(
                    errorCode: Int,
                    errorString: String?,
                    t: Throwable?
                ) {
                    callback.invoke(Result.failure(t ?: throw FlutterError("Scan Qr failure")))
                }
            })
    }

    override fun kinit(
        dssUser: DssUser,
        registerInfo: DSSRegisterInfo,
        keyProtectionType: DSSProtectionType,
        activationCode: String?,
        password: String?,
        callback: (Result<String>) -> Unit
    ) {
        auth.kinit(
            context,
            dssUser.toNativeModel(),
            registerInfo.toNativeModel(),
            keyProtectionType.toNativeModel(),
            activationCode,
            password,
            object : SdkResultCallback<String> {
                override fun onOperationSuccessful(result: String) {
                    callback.invoke(Result.success(result))
                }

                override fun onOperationFailed(
                    errorCode: Int,
                    errorString: String?,
                    t: Throwable?
                ) {
                    callback.invoke(Result.failure(t ?: FlutterError("kinit Error")))
                }

            })
    }

    override fun confirm(
        kid: String,
        callback: (Result<Unit>) -> Unit
    ) {
        auth.confirm(context, kid, object : SdkResultCallback<Unit> {
            override fun onOperationSuccessful(result: Unit) {
                callback.invoke(Result.success(Unit))
            }

            override fun onOperationFailed(
                errorCode: Int,
                errorString: String?,
                t: Throwable?
            ) {
                callback.invoke(Result.failure(t ?: FlutterError("confirm error")))
            }

        })
    }

    override fun verifyDevice(
        kid: String,
        silent: Boolean,
        callback: (Result<Unit>) -> Unit
    ) {
        auth.verify(
            context,
            kid,
            silent,
            object : SdkResultCallback<Unit> {
                override fun onOperationSuccessful(result: Unit) {
                    callback.invoke(Result.success(Unit))
                }

                override fun onOperationFailed(
                    errorCode: Int,
                    errorString: String?,
                    t: Throwable?
                ) {
                    callback.invoke(Result.failure(t ?: FlutterError("verify error")))
                }
            })
    }

    override fun removeAuth(
        request: RemoveAuthRequest,
        callback: (Result<Unit>) -> Unit
    ) {
        auth.removeAuth(
            context,
            request.kid,
            request.deletedKid,
            true,
            object : SdkResultCallback<Unit> {
                override fun onOperationSuccessful(result: Unit) {
                    callback.invoke(Result.success(result))
                }

                override fun onOperationFailed(
                    errorCode: Int,
                    errorString: String?,
                    t: Throwable?
                ) {
                    callback.invoke(Result.failure(t ?: FlutterError("verify error")))
                }

            })
    }
}
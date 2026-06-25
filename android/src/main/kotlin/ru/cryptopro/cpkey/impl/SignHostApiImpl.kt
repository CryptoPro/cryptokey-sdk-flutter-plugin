package ru.cryptopro.cpkey.impl

import DssConfirmationSendingMode
import DssOperation
import DssSignMtResult
import FlutterError
import SignHostApi
import android.content.Context
import ru.cryptopro.cpkey.mappers.toPigeon
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultCallback
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultMtOperationType
import ru.cryptopro.cryptokey.presentation.external.policy.Policy
import ru.cryptopro.cryptokey.presentation.external.sign.Sign
import ru.cryptopro.cryptokey.presentation.external.sign.models.OperationsInfo

class SignHostApiImpl(
    private val context: Context
) : SignHostApi {

    val sign = Sign()

    override fun signMt(
        kid: String,
        operation: DssOperation?,
        enableMultiSelection: Boolean,
        confirmationSendingMode: DssConfirmationSendingMode,
        pinCode: String?,
        silent: Boolean,
        callback: (Result<DssSignMtResult>) -> Unit,
    ) {
        Policy().getOperations(
            context,
            kid,
            null,
            opId = null,
            null,
            object : SdkResultCallback<OperationsInfo> {
                override fun onOperationSuccessful(result: OperationsInfo) {
                    val nativeOperation = result.operations.firstOrNull {
                        it.transactionId == operation?.transactionId &&
                                it.createdAt == operation?.createdAt &&
                                it.expireAt == operation.expiresAt &&
                                it.description.description == operation.description.description
                    }

                    if (nativeOperation == null) {
                        callback(
                            Result.failure(
                                FlutterError(
                                    code = "OPERATION_NOT_FOUND",
                                    message = "Операция не найдена среди доступных",
                                    details = null
                                )
                            )
                        )
                        return
                    }

                    sign.signMT(
                        context = context,
                        kid = kid,
                        operation = nativeOperation,
                        enableMultiSelection = enableMultiSelection,
                        immediateSendConfirm = confirmationSendingMode.toPigeon(),
                        silent = silent,
                        sdkResultCallback = object : SdkResultCallback<SdkResultMtOperationType> {
                            override fun onOperationSuccessful(result: SdkResultMtOperationType) {
                                val pigeonResult = when (result) {
                                    is SdkResultMtOperationType.MtOperationSuccess -> DssSignMtResult(
                                        resultType = DssSignMtResultType.SUCCESS,
                                        confirmState = result.confirmState?.toPigeon(),
                                        approveRequest = null,
                                        documentsWithErrors = null,
                                        documentErrors = null,
                                    )

                                    is SdkResultMtOperationType.MtOperationPartialSuccess -> DssSignMtResult(
                                        resultType = DssSignMtResultType.PARTIAL_SUCCESS,
                                        confirmState = result.confirmState?.toPigeon(),
                                        approveRequest = null,
                                        documentsWithErrors = result.documentWithErrorList.map { it.toPigeon() },
                                        documentErrors = null,
                                    )

                                    is SdkResultMtOperationType.MtOperationSuspendedConfirm -> DssSignMtResult(
                                        resultType = DssSignMtResultType.SUSPENDED_CONFIRM,
                                        confirmState = null,
                                        approveRequest = result.approveRequestMT.toPigeon(),
                                        documentsWithErrors = null,
                                        documentErrors = null,
                                    )
                                }
                                callback(Result.success(pigeonResult))
                            }

                            override fun onOperationFailed(
                                errorCode: Int,
                                errorString: String?,
                                t: Throwable?
                            ) {
                                callback(
                                    Result.failure(
                                        FlutterError(
                                            code = errorCode.toString(),
                                            message = errorString ?: "Ошибка подписи MT",
                                            details = t?.message
                                        )
                                    )
                                )
                            }
                        }
                    )
                }

                override fun onOperationFailed(
                    errorCode: Int,
                    errorString: String?,
                    t: Throwable?
                ) {
                    callback(
                        Result.failure(
                            FlutterError(
                                code = errorCode.toString(),
                                message = errorString ?: "Ошибка получения операций",
                                details = t?.message
                            )
                        )
                    )
                }
            }
        )
    }
}
package ru.cryptopro.cpkey.mappers

import DssAppSystemDescription
import DssApproveRequestMt
import DssApprovedOperation
import DssConfirmState
import DssConfirmationSendingMode
import DssConfirmedDocument
import DssDeclinedDocument
import DssDocument
import DssOperation
import DssOperationDescription
import DssOperationParameters
import DssOperationsInfo
import DssSignMtResult
import kotlinx.serialization.json.Json
import ru.cryptopro.cryptokey.data.repositories.sign.model.request.ApproveRequestMT
import ru.cryptopro.cryptokey.data.repositories.sign.model.request.ApprovedOperationMt
import ru.cryptopro.cryptokey.data.repositories.sign.model.request.ConfirmRequest
import ru.cryptopro.cryptokey.data.repositories.sign.model.request.DeclineRequest
import ru.cryptopro.cryptokey.presentation.external.docs.models.Document
import ru.cryptopro.cryptokey.presentation.external.interfaces.SdkResultMtOperationType
import ru.cryptopro.cryptokey.presentation.external.sign.models.AppSystemDescription
import ru.cryptopro.cryptokey.presentation.external.sign.models.ConfirmStateEnum
import ru.cryptopro.cryptokey.presentation.external.sign.models.Operation
import ru.cryptopro.cryptokey.presentation.external.sign.models.OperationDescription
import ru.cryptopro.cryptokey.presentation.external.sign.models.OperationParameters
import ru.cryptopro.cryptokey.presentation.external.sign.models.OperationsInfo

fun OperationsInfo.toPigeon(): DssOperationsInfo {
    return DssOperationsInfo(
        operations = this.operations.map { it.toPigeon() },
        kid = null // Android — нет kid
    )
}

fun Operation.toPigeon(): DssOperation {
    return DssOperation(
        description = this.description.toPigeon(),
        createdAt = this.createdAt,
        expiresAt = this.expireAt,
        expiresIn = this.expiresIn,
        documentCount = this.documentCount.toLong(),
        transactionId = this.transactionId,
        parameters = this.parameters.toPigeon(),
        documents = this.documents.map { it.toPigeon() },
        kid = null, // Android — нет kid
        isClientSide = this.isClientSide,
        isFullDocRequired = this.isFullDocRequired,
        certificateId = this.certificateId,
        appSystemInfo = this.appSystemInfo?.toPigeon(),
        documentSelectionMode = this.documentSelectionMode!!,
        isInstantDocumentView = this.isInstantDocumentView,
        isLocalDocumentView = this.isLocalDocumentView,
        dskProtocolVersion = this.dskProtocolVersion?.toLong(),
        dskTicketSigningCert = this.dskTicketSigningCert
    )
}

fun OperationParameters?.toPigeon(): DssOperationParameters? {
    if (this == null) return null
    return DssOperationParameters(
        encryptionType = this.encryptionType().name,
        useFssScenario = this.isUseFssScenario().toString(),
        signatureType = this.signatureType().name,
        isDetached = this.isDetached().toString()
    )
}

fun OperationDescription.toPigeon(): DssOperationDescription {
    return DssOperationDescription(
        type = this.type,
        caption = this.caption,
        description = this.description
    )
}

fun Document.toPigeon(): DssDocument {
    return DssDocument(
        id = this.id,
        title = this.title,
        hash = this.hash,
        snippet = this.snippet,
        snippetHash = this.snippetHash,
        fileSize = (this.size * 1024 * 1024).toLong(), // MB → bytes
        pageCount = this.pageCount.toLong(),
        isPrintableViewAvailable = this.isPrintableViewAvailable,
        isSnippetViewAvailable = this.isSnippetViewAvailable,
        isRawViewAvailable = this.isRawViewAvailable,
        order = null, // Только iOS
        fileBytes = this.fileBytes,
    )
}

fun AppSystemDescription.toPigeon(): DssAppSystemDescription {
    return DssAppSystemDescription(
        clientId = this.clientId,
        title = this.title,
        description = this.description
    )
}

fun DssConfirmationSendingMode.toPigeon(): Boolean {
    return when (this) {
        DssConfirmationSendingMode.ONLINE -> true
        DssConfirmationSendingMode.OFFLINE -> false
    }
}

fun ConfirmStateEnum.toPigeon(): DssConfirmState {
    return when (this) {
        ConfirmStateEnum.CONFIRMED -> DssConfirmState.CONFIRMED
        ConfirmStateEnum.DECLINED -> DssConfirmState.DECLINED
        ConfirmStateEnum.UNKNOWN -> DssConfirmState.UNKNOWN
    }
}

fun ApprovedOperationMt.toPigeon(): DssApprovedOperation {
    return DssApprovedOperation(
        id = this.id!!,
        type = this.type!!.toString(),
        caption = "", // отсутствует в Android SDK
        parameters = this.parameters as Map<String?, String?>?,
        confirmedDocuments = this.confirmedDocuments?.map { it.toDssConfirmedDocument() },
        declinedDocuments = this.declinedDocuments?.map { it.toDssDeclinedDocument() },
        timeStamp = this.timeStamp,
    )
}

fun ConfirmRequest.toDssConfirmedDocument(): DssConfirmedDocument {
    return DssConfirmedDocument(
        id = this.id,
        hash = this.hash,
    )
}

fun DeclineRequest.toDssDeclinedDocument(): DssDeclinedDocument {
    return DssDeclinedDocument(
        id = this.id,
        hash = this.hash,
    )
}

private val json = Json { ignoreUnknownKeys = true }

fun ApproveRequestMT.toPigeon(): DssApproveRequestMt {
    val approvedOp = json.decodeFromString<ApprovedOperationMt>(this.approvedOperation)
    return DssApproveRequestMt(
        approvedOperation = approvedOp.toPigeon(),
        hmac = this.hmac,
    )
}

fun SdkResultMtOperationType.toPigeon(): DssSignMtResult {
    return when (this) {
        is SdkResultMtOperationType.MtOperationSuccess -> DssSignMtResult(
            resultType = DssSignMtResultType.SUCCESS,
            confirmState = this.confirmState?.toPigeon(),
            approveRequest = null,
            documentsWithErrors = null,
            documentErrors = null,
        )

        is SdkResultMtOperationType.MtOperationPartialSuccess -> DssSignMtResult(
            resultType = DssSignMtResultType.PARTIAL_SUCCESS,
            confirmState = this.confirmState?.toPigeon(),
            approveRequest = null,
            documentsWithErrors = this.documentWithErrorList.map { it.toPigeon() },
            documentErrors = null,
        )

        is SdkResultMtOperationType.MtOperationSuspendedConfirm -> DssSignMtResult(
            resultType = DssSignMtResultType.SUSPENDED_CONFIRM,
            confirmState = null,
            approveRequest = this.approveRequestMT.toPigeon(),
            documentsWithErrors = null,
            documentErrors = null,
        )

        else -> throw IllegalArgumentException(
            "Unknown SdkResultMtOperationType: ${this::class.java.simpleName}"
        )
    }
}
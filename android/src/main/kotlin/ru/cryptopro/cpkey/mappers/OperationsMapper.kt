package ru.cryptopro.cpkey.mappers

import DssAppSystemDescription
import DssDocument
import DssOperation
import DssOperationDescription
import DssOperationParameters
import DssOperationsInfo
import ru.cryptopro.cryptokey.presentation.external.docs.models.Document
import ru.cryptopro.cryptokey.presentation.external.sign.models.AppSystemDescription
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
        name = this.title
    )
}

fun AppSystemDescription.toPigeon(): DssAppSystemDescription {
    return DssAppSystemDescription(
        clientId = this.clientId,
        title = this.title,
        description = this.description
    )
}
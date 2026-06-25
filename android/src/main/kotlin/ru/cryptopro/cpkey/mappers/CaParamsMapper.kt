package ru.cryptopro.cpkey.mappers

import DssCaParams
import DssCaPolicy
import DssCryptoProviderInfo
import DssExtensionsPolicy
import DssNamePolicy
import DssProcessingTemplate
import FlutterError
import android.annotation.SuppressLint
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.decodeFromJsonElement
import ru.cryptopro.cryptokey.presentation.external.policy.model.CAPolicy
import ru.cryptopro.cryptokey.presentation.external.policy.model.CaParams
import ru.cryptopro.cryptokey.presentation.external.policy.model.CryptoProviderInfo
import ru.cryptopro.cryptokey.presentation.external.policy.model.NamePolicy
import ru.cryptopro.cryptokey.presentation.external.policy.model.ProcessingTemplate

fun CaParams.toPigeon(): DssCaParams {
    return DssCaParams(
        caPolicies = caPolicies.map { it.toPigeon() },
        processingTemplates = processingTemplates.map { it.toPigeon() },
        isMobileKeysSupported = isMobileKeysSupported(),
        isDskKeysSupported = isDskKeysSupported(),
        isServerKeysSupported = isServerKeysSupported(),
    )
}

fun CAPolicy.toPigeon(): DssCaPolicy {
    return DssCaPolicy(
        id = id.toLong(),
        name = name,
        active = active,
        allowUserMode = allowUserMode,
        snChangesEnable = snChangesEnable,
        namePolicy = namePolicy.map { it.toPigeon() },
        caType = caType?.name,
        validationMode = validationMode,
        showInUI = showInUI,
        extensionsPolicy = extensionsPolicy?.toExtensionsPolicyList(),
        ekuTemplates = getEkuTemplates()?.mapValues { (_, values) ->
            values.toList()
        },
        cryptoProviderInfos = cryptoProviderInfos?.mapValues { (_, infos) ->
            infos.map { it.toPigeon() }
        },
        supportedFlows = supportedFlows?.toList(),
        mdipServiceAddress = mdipServiceAddress,
        mdipPreferedEnrollId = mdipPreferedEnrollId,
    )
}

private val json = Json { ignoreUnknownKeys = true }

@SuppressLint("UnsafeOptInUsageError")
@Serializable
private data class ExtensionsPolicyDto(
    val oid: String,
    val value: String = "",
    val critical: Boolean = false,
)

private fun JsonElement.toExtensionsPolicyList(): List<DssExtensionsPolicy> {
    return try {
        val dtoList = json.decodeFromJsonElement<List<ExtensionsPolicyDto>>(this)
        dtoList.map { dto ->
            DssExtensionsPolicy(
                oid = dto.oid,
                value = dto.value,
                critical = dto.critical,
            )
        }
    } catch (e: Exception) {
        throw FlutterError("error when parsing CaPolicy")
    }
}

fun CryptoProviderInfo.toPigeon(): DssCryptoProviderInfo {
    return DssCryptoProviderInfo(
        provType = provType,
        provName = "name not provided",
        priority = priority,
        containerName = null,
    )
}

fun DssCryptoProviderInfo.toNative(): CryptoProviderInfo {
    return CryptoProviderInfo(
        provType = provType,
        priority = priority!!,
    )
}

fun NamePolicy.toPigeon(): DssNamePolicy {
    return DssNamePolicy(
        isRequired = isRequired,
        order = order,
        oid = oid,
        name = name,
        value = value?.toString(), // JsonElement? → String?
        stringIdentifier = stringIdentifier,
    )
}

fun ProcessingTemplate.toPigeon(): DssProcessingTemplate {
    return DssProcessingTemplate(
        id = id,
        description = description,
    )
}

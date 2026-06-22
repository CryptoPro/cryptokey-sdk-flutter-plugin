package ru.cryptopro.cpkey.mappers

import DSSRegisterInfo
import ru.cryptopro.cryptokey.presentation.external.auth.models.RegisterInfo

fun DSSRegisterInfo.toNativeModel(): RegisterInfo {
    return RegisterInfo(
        pushAddress = this@toNativeModel.pushAddress,
        appVersion = this@toNativeModel.appVersion,
        userName = this@toNativeModel.userName, // В Android SDK это поле соответствует логину пользователя
        phone = this@toNativeModel.phone,
        email = this@toNativeModel.email,
        token = this@toNativeModel.token,
        // Если deviceName не заполнено, SDK обычно само ставит "Android", либо мы можем подставить вручную
        deviceName = this@toNativeModel.deviceName ?: "Android",
        deviceType = this@toNativeModel.deviceType?.toNativeModel() ?: RegisterInfo.DeviceType.ANDROID
    )
}
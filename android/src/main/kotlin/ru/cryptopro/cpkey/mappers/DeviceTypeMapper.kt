package ru.cryptopro.cpkey.mappers

import DSSDeviceType
import ru.cryptopro.cryptokey.presentation.external.auth.models.RegisterInfo

fun DSSDeviceType.toNativeModel(): RegisterInfo.DeviceType {
    return when (this) {
        DSSDeviceType.ANDROID -> RegisterInfo.DeviceType.ANDROID
        DSSDeviceType.HUAWEI -> RegisterInfo.DeviceType.HUAWEI
    }
}
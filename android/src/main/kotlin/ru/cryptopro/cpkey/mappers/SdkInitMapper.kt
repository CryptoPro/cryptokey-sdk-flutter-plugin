package ru.cryptopro.cpkey.mappers

import SdkInitCode
import ru.cryptopro.cryptokey.initialization.model.CSPInitCode

object SdkInitMapper {

    fun mapInitCode(native: CSPInitCode): SdkInitCode {
        return when (native) {
            CSPInitCode.initOk -> SdkInitCode.INIT_OK
            CSPInitCode.initCertNotInstalled -> SdkInitCode.INIT_CERTS_NOT_INSTALLED
            CSPInitCode.initLockScreenNotInstalled -> SdkInitCode.INIT_LOCK_SCREEN_NOT_INSTALLED
            CSPInitCode.initDeviceRooted -> SdkInitCode.INIT_DEVICE_ROOTED
            CSPInitCode.initDeviceHasSpyPrograms -> SdkInitCode.INIT_DEVICE_HAS_SPY_PROGRAMS
            CSPInitCode.initCspNotInitialized -> SdkInitCode.INIT_CSP_NOT_INITIALIZED
            CSPInitCode.initRootCertNotInitializedWrongHash -> SdkInitCode.INIT_ROOT_CERT_NOT_INITIALIZED_WRONG_HASH
            CSPInitCode.initRootCertNotInitializedWrongSign -> SdkInitCode.INIT_ROOT_CERT_NOT_INITIALIZED_WRONG_SIGN
            CSPInitCode.initRootCertNotInitializedWrongASNTag -> SdkInitCode.INIT_ROOT_CERT_NOT_INITIALIZED_WRONG_ASNTAG
            else -> throw Exception("unknown native status of CSPInitCode")
        }
    }
}
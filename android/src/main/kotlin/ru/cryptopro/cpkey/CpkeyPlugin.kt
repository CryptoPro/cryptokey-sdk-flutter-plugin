package ru.cryptopro.cpkey

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import ru.cryptopro.cpkey.impl.AuthHostApiImpl
import ru.cryptopro.cpkey.impl.CertHostApiImpl
import ru.cryptopro.cpkey.impl.CryptoProDssHostApiImpl
import ru.cryptopro.cpkey.impl.PolicyHostApiImpl
import ru.cryptopro.cpkey.impl.SignHostApiImpl
import ru.cryptopro.cpkey.impl.SigningKeyHostApiImpl

class CpkeyPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var cryptoProDssHostApiImpl: CryptoProDssHostApiImpl? = null
    private var authHostApiImpl: AuthHostApiImpl? = null
    private var policyHostApiImpl: PolicyHostApiImpl? = null
    private var certHostApiImpl: CertHostApiImpl? = null
    private var signHostApiImpl: SignHostApiImpl? = null
    private var signingKeyHostApiImpl: SigningKeyHostApiImpl? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cpkey")
        channel.setMethodCallHandler(this)

        val context = flutterPluginBinding.applicationContext
        cryptoProDssHostApiImpl = CryptoProDssHostApiImpl(context)
        authHostApiImpl = AuthHostApiImpl(context)
        policyHostApiImpl = PolicyHostApiImpl(context)
        certHostApiImpl = CertHostApiImpl(context)
        signHostApiImpl = SignHostApiImpl(context)
        signingKeyHostApiImpl = SigningKeyHostApiImpl(context)

        CryptoProDssHostApi.setUp(flutterPluginBinding.binaryMessenger, cryptoProDssHostApiImpl)
        AuthHostApi.setUp(flutterPluginBinding.binaryMessenger, authHostApiImpl)
        PolicyHostApi.setUp(flutterPluginBinding.binaryMessenger, policyHostApiImpl)
        CertHostApi.setUp(flutterPluginBinding.binaryMessenger, certHostApiImpl)
        SignHostApi.setUp(flutterPluginBinding.binaryMessenger, signHostApiImpl)
        SigningKeyHostApi.setUp(flutterPluginBinding.binaryMessenger, signingKeyHostApiImpl)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Освобождаем ресурсы и отвязываем каналы
        channel.setMethodCallHandler(null)

        // Отвязываем Pigeon API, передавая null
        CryptoProDssHostApi.setUp(binding.binaryMessenger, null)
        cryptoProDssHostApiImpl = null
        authHostApiImpl = null
        policyHostApiImpl = null
        certHostApiImpl = null
        signHostApiImpl = null
        signingKeyHostApiImpl = null
    }
}

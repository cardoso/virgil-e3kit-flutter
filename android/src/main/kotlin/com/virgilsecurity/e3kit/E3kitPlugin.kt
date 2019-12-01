package com.virgilsecurity.e3kit

import android.app.Activity
import android.content.Context
import com.virgilsecurity.android.common.callback.OnGetTokenCallback
import com.virgilsecurity.android.ethree.interaction.EThree
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.Semaphore

class E3kitPlugin: MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "plugins.virgilsecurity.com/e3kit")
            channel.setMethodCallHandler(E3kitPlugin(registrar.activity(), registrar.context(), channel))
        }
    }

    val activity: Activity
    val context: Context
    val channel: MethodChannel
    val eThrees = HashMap<String, FlutterEThree>()

    constructor(activity: Activity, context: Context, channel: MethodChannel) {
        this.activity = activity
        this.context = context
        this.channel = channel
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments as? HashMap<String, Any>
        val instanceId = arguments!!["_id"] as String?
                ?: return result.error(
                        "argument_not_found",
                        "Could not find argument `_id` of type String",
                        null
                )

        if (call.method == "init") {
            val identity = arguments["identity"] as? String
                    ?: return result.error(
                            "argument_not_found",
                            "Could not find argument `identity` of type String",
                            null
                    )
            val eThree = EThree(identity, object : OnGetTokenCallback {
                override fun onGetToken(): String {
                    var token: String? = null
                    var error: String? = null
                    var notImplemented: Boolean? = null

                    val semaphore = Semaphore(0)

                    activity.runOnUiThread {
                        channel.invokeMethod("tokenCallback", hashMapOf("_id" to instanceId), object : MethodChannel.Result {
                            override fun success(p0: Any?) {
                                token = p0 as? String
                                semaphore.release()
                            }

                            override fun error(p0: String?, p1: String?, p2: Any?) {
                                error = "$p0: $p1"
                                semaphore.release()
                            }

                            override fun notImplemented() {
                                notImplemented = true
                                semaphore.release()
                            }
                        })
                    }

                    // Because E3Kit for Android doesn't support async onGetToken
                    // And Flutter's Platform Channels are asynchronous
                    semaphore.acquire()

                    return token ?: throw Error(error)
                }
            }, context)

            eThrees[instanceId] = FlutterEThree(eThree, channel, activity)
            result.success(true)
        } else {
            val eThree = eThrees[instanceId]

            if(eThree !is FlutterEThree) {
                return result.error(
                        "not_initialized",
                        "EThree instance is not initialized",
                        null
                )
            }

            eThree.invoke(call, result)
        }
    }
}

package com.virgilsecurity.e3kit

import android.app.Activity
import android.os.AsyncTask
import android.os.Looper
import com.virgilsecurity.android.common.model.FindUsersResult
import com.virgilsecurity.android.ethree.interaction.EThree
import com.virgilsecurity.common.callback.OnCompleteListener
import com.virgilsecurity.common.callback.OnResultListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class FlutterEThree {
    val instance: EThree
    val channel: MethodChannel
    val activity: Activity

    constructor(instance: EThree, channel: MethodChannel, activity: Activity) {
        this.instance = instance
        this.channel = channel
        this.activity = activity
    }

    fun invoke(call: MethodCall, result: MethodChannel.Result) {
        fun <T: Any>getArgument(argument: String, optional: Boolean = false): T {
            val arg = (call.arguments as? HashMap<String, Any>)?.getValue(argument) as? T

            if(!optional && arg == null) {
                val errorCode = "argument_not_found"
                val errorMessage = "Could not find argument `$argument` of type ${arg?.javaClass?.name}"
                result.error(errorCode, errorMessage, null)
                throw Error("$errorCode: $errorMessage")
            }

            return arg!!
        }

        fun <T: Any>getOptionalArgument(argument: String): T? {
            return try {
                getArgument(argument, true)
            } catch(e: Throwable) {
                null
            }
        }


        try {
            when (call.method) {
                "getIdentity" -> getIdentity(result)
                "hasLocalPrivateKey" -> hasLocalPrivateKey(result)
                "register" -> register(result)
                "rotatePrivateKey" -> rotatePrivateKey(result)
                "cleanUp" -> cleanUp(result)
                "findUsers" -> findUsers(
                        getArgument("identities"),
                        result
                )
                "encrypt" -> encrypt(
                        getArgument("text"),
                        getOptionalArgument("users"),
                        result
                )
                "decrypt" -> decrypt(
                        getArgument("text"),
                        getOptionalArgument("user"),
                        result
                )
                "backupPrivateKey" -> backupPrivateKey(
                    getArgument("password"),
                    result
                )
                "resetPrivateKeyBackup" -> resetPrivateKeyBackup(result)
                "changePassword" -> changePassword(
                    getArgument("oldPassword"),
                    getArgument("newPassword"),
                    result
                )
                "restorePrivateKey" -> restorePrivateKey(
                        getArgument("password"),
                        result
                )
                "unregister" -> unregister(result)
                else -> activity.runOnUiThread {
                    result.error(
                            "method_not_recognized",
                            "Method is not recognized",
                            "Method name: '${call.method}'"
                    )
                }
            }
        } catch(e: Throwable) {
            result.error(e.toFlutterError())
        }
    }

    private fun getIdentity(result: MethodChannel.Result) {
        activity.runOnUiThread {
            result.success(instance.identity)
        }
    }

    private fun hasLocalPrivateKey(result: MethodChannel.Result) {
        activity.runOnUiThread {
            result.success(instance.hasLocalPrivateKey())
        }
    }

    private fun register(result: MethodChannel.Result) {
        instance.register().addCallback(object: OnCompleteListener {
            override fun onSuccess() {
                activity.runOnUiThread {
                    result.success(true)
                }
            }
            override fun onError(throwable: Throwable) {
                activity.runOnUiThread {
                    result.error(throwable.toFlutterError())
                }
            }
        })
    }

    private fun rotatePrivateKey(result: MethodChannel.Result) {
        instance.rotatePrivateKey().addCallback(object: OnCompleteListener {
            override fun onSuccess() {
                activity.runOnUiThread {
                    result.success(true)
                }
            }
            override fun onError(throwable: Throwable) {
                activity.runOnUiThread {
                    result.error(throwable.toFlutterError())
                }
            }
        })
    }

    private fun cleanUp(result: MethodChannel.Result) {
        AsyncTask.execute {
            try {
                instance.cleanup()
            } catch(e: Throwable) {
                activity.runOnUiThread {
                    result.error(e.toFlutterError())
                }
                
                return@execute
            }

            activity.runOnUiThread {
                result.success(true)
            }
        }
    }

    private fun findUsers(identities: List<String>, result: MethodChannel.Result) {
        instance.findUsers(identities, true).addCallback(object: OnResultListener<FindUsersResult> {
            override fun onSuccess(res: FindUsersResult) {
                val mapped = res.mapValues {
                    it.value.rawCard.exportAsBase64String()!!
                }

                activity.runOnUiThread {
                    result.success(mapped)
                }
            }
            override fun onError(throwable: Throwable) {
                activity.runOnUiThread {
                    result.error(throwable.toFlutterError())
                }
            }
        })
    }

    private fun encrypt(
            text: String,
            users: HashMap<String, String>? = null,
            result: MethodChannel.Result
    ) {
        val mapped = users?.mapValues {
            instance.cardManager.importCardAsString(it.value)!!
        }

        val findUsersResult = if (mapped != null) FindUsersResult(mapped) else null

        val res = instance.encrypt(text, findUsersResult)

        result.success(res)
    }

    private fun decrypt(
            text: String,
            user: String? = null,
            result: MethodChannel.Result
    ) {
        val imported = instance.cardManager.importCardAsString(user)
        val res = instance.decrypt(text, imported)

        result.success(res)
    }

    private fun backupPrivateKey(password: String, result: MethodChannel.Result) {
        instance.backupPrivateKey(password).addCallback(object: OnCompleteListener {
            override fun onSuccess() {
                activity.runOnUiThread {
                    result.success(true)
                }
            }
            override fun onError(throwable: Throwable) {
                activity.runOnUiThread {
                    result.error(throwable.toFlutterError())
                }
            }
        })
    }

    private fun resetPrivateKeyBackup(result: MethodChannel.Result) {
        instance.resetPrivateKeyBackup().addCallback(object: OnCompleteListener {
            override fun onSuccess() {
                activity.runOnUiThread {
                    result.success(true)
                }
            }
            override fun onError(throwable: Throwable) {
                activity.runOnUiThread {
                    result.error(throwable.toFlutterError())
                }
            }
        })
    }

    private fun changePassword(oldPassword: String, newPassword: String, result: MethodChannel.Result) {
        instance.changePassword(oldPassword, newPassword).addCallback(object: OnCompleteListener {
            override fun onSuccess() {
                activity.runOnUiThread {
                    result.success(true)
                }
            }
            override fun onError(throwable: Throwable) {
                activity.runOnUiThread {
                    result.error(throwable.toFlutterError())
                }
            }
        })
    }

    private fun restorePrivateKey(password: String, result: MethodChannel.Result) {
        instance.restorePrivateKey(password).addCallback(object: OnCompleteListener {
            override fun onSuccess() {
                activity.runOnUiThread {
                    result.success(true)
                }
            }
            override fun onError(throwable: Throwable) {
                activity.runOnUiThread {
                    result.error(throwable.toFlutterError())
                }
            }
        })
    }

    private fun unregister(result: MethodChannel.Result) {
        instance.unregister().addCallback(object: OnCompleteListener {
            override fun onSuccess() {
                activity.runOnUiThread {
                    result.success(true)
                }
            }
            override fun onError(throwable: Throwable) {
                activity.runOnUiThread {
                    result.error(throwable.toFlutterError())
                }
            }
        })
    }
}
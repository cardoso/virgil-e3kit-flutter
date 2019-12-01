package com.virgilsecurity.e3kit

import com.virgilsecurity.android.common.exception.EThreeException
import com.virgilsecurity.android.common.exception.PrivateKeyNotFoundException
import io.flutter.plugin.common.MethodChannel

typealias FlutterError = Triple<String?, String?, Any?>

fun MethodChannel.Result.error(error: FlutterError) {
    this.error(error.first, error.second, error.third)
}

fun Throwable.defaultFlutterError(): FlutterError {
    return FlutterError(
            "unknown_error",
            message,
            null
    )
}

fun Throwable.toFlutterError(): FlutterError {
    if(this is EThreeException) {
        return this.toFlutterError()
    }

    if(this is PrivateKeyNotFoundException) {
        return this.toFlutterError()
    }

    return this.defaultFlutterError()
}

fun EThreeException.toFlutterError(): FlutterError {
    if(this.message == "User is already registered") {
        return FlutterError(
                "user_is_already_registered",
                message,
                null
        )
    }

    if(this.message == "Private key already exists in local key storage.") {
        return FlutterError(
                "private_key_exists",
                message,
                null
        )
    }

    return this.defaultFlutterError()
}

fun PrivateKeyNotFoundException.toFlutterError(): FlutterError {
    return FlutterError(
            "missing_private_key",
            message,
            null
    )
}
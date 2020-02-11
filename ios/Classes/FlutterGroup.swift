//
//  FlutterGroup.swift
//  e3kit
//
//  Created by Matheus Cardoso on 2/6/20.
//

import VirgilE3Kit
import VirgilSDK
import VirgilCrypto

struct FlutterGroup {
    let origin: EThree
    let instance: Group
    let channel: FlutterMethodChannel

    func invoke(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        switch call.method {
        case "encrypt": encrypt(
            text: try call.getArgument("text"),
            result
        )
        case "decrypt": decrypt(
            text: try call.getArgument("text"),
            user: try call.getArgument("user"),
            result
        )
        default:
            result(FlutterError(
                code: "method_not_recognized",
                message: "Method is not recognized",
                details: "Method name: '\(call.method)'"
            ))
        }
    }

    func encrypt(
        text: String,
        _ result: @escaping FlutterResult
    ) {
        do {
            result(try instance.encrypt(text: text))
        } catch let error {
            return result(error.toFlutterError())
        }
    }

    func decrypt(
        text: String,
        user: String,
        _ result: @escaping FlutterResult
    ) {
        do {
            let card = try origin
                .cardManager
                .importCard(fromBase64Encoded: user)

            return result(try instance.decrypt(text: text, from: card))
        } catch let error {
            return result(error.toFlutterError())
        }
    }
}


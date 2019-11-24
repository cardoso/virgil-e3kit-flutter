//
//  FlutterEThree.swift
//  e3kit
//
//  Created by Matheus Cardoso on 11/12/19.
//

import VirgilE3Kit
import VirgilSDK
import VirgilCrypto

struct FlutterEThree {
    let instance: EThree
    let channel: FlutterMethodChannel

    func invoke(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        func getArgument<T>(_ argument: String, optional: Bool = false) throws -> T {
            if let arg = (call.arguments as? [String: Any])?[argument] as? T {
                return arg
            } else {
                let error = FlutterError(
                    code: "argument_not_found",
                    message: "Could not find argument `\(argument)` of type \(T.self)",
                    details: nil
                )

                if !optional { result(error) }

                throw error
            }
        }

        func getOptionalArgument<T>(_ argument: String) -> T? {
            return try? getArgument(argument, optional: true)
        }

        switch call.method {
        case "getIdentity": getIdentity(result)
        case "hasLocalPrivateKey": hasLocalPrivateKey(result)
        case "register": register(result)
        case "rotatePrivateKey": rotatePrivateKey(result)
        case "cleanUp": cleanUp(result)
        case "findUsers": findUsers(
            try getArgument("identities"),
            result
        )
        case "encrypt": encrypt(
            text: try getArgument("text"),
            for: getOptionalArgument("users"),
            result
        )
        case "decrypt": decrypt(
            text: try getArgument("text"),
            from: getOptionalArgument("user"),
            result
        )
        case "backupPrivateKey": backupPrivateKey(
            password: try getArgument("password"),
            result
        )
        case "resetPrivateKeyBackup": resetPrivateKeyBackup(result)
        case "changePassword": changePassword(
            from: try getArgument("oldPassword"),
            to: try getArgument("newPassword"),
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

    func getIdentity(_ result: @escaping FlutterResult) {
        result(instance.identity)
    }

    func hasLocalPrivateKey(_ result: @escaping FlutterResult) {
        do {
            result(try instance.hasLocalPrivateKey())
        } catch let error {
            return result(error.toFlutterError())
        }
    }

    func register(_ result: @escaping FlutterResult) {
        instance.register(completion: { error in
            if let error = error {
                return result(error.toFlutterError())
            }

            return result(true)
        })
    }

    func rotatePrivateKey(_ result: @escaping FlutterResult) {
        instance.rotatePrivateKey(completion: { error in
            if let error = error {
                return result(error.toFlutterError())
            }

            return result(true)
        })
    }

    func cleanUp(_ result: @escaping FlutterResult) {
        do {
            try instance.cleanUp()
            return result(true)
        } catch let error {
            return result(error.toFlutterError())
        }
    }

    func findUsers(_ identities: [String], _ result: @escaping FlutterResult) {
        instance.findUsers(with: identities).start(completion: { res, error in
            if let error = error {
                return result(FlutterError(
                    code: "find_users_failed",
                    message: "Failed to find users",
                    details: error.localizedDescription
                ))
            }

            guard let res = res else {
                return result(FlutterError(
                    code: "find_users_failed",
                    message: "Failed to find users",
                    details: "Result is null"
                ))
            }

            do {
                let res = try res.compactMapValues({
                    try $0.getRawCard().exportAsBase64EncodedString()
                })

                return result(res)
            } catch let error {
                return result(FlutterError(
                    code: "find_users_failed",
                    message: "Could not encode result",
                    details: error.localizedDescription
                ))
            }
        })
    }

    func encrypt(
        text: String,
        for users: [String: String]? = nil,
        _ result: @escaping FlutterResult
    ) {
        do {
            let users = try users?.mapValues {
                try instance.cardManager.importCard(fromBase64Encoded: $0)
            }

            result(try instance.encrypt(text: text, for: users))
        } catch let error {
            return result(error.toFlutterError())
        }
    }

    func decrypt(
        text: String,
        from user: String?,
        _ result: @escaping FlutterResult
    ) {
        do {
            if let user = user {
                let card = try instance
                    .cardManager
                    .importCard(fromBase64Encoded: user)

                return result(try instance.decrypt(text: text, from: card))
            }

            return result(try instance.decrypt(text: text))
        } catch let error {
            return result(error.toFlutterError())
        }
    }

    func backupPrivateKey(
        password: String,
        _ result: @escaping FlutterResult
    ) {
        instance.backupPrivateKey(password: password).start { res in
            switch res {
            case .success:
                return result(true)
            case .failure(let error):
                return result(error.toFlutterError())
            }
        }
    }

    func resetPrivateKeyBackup(_ result: @escaping FlutterResult) {
        instance.resetPrivateKeyBackup().start { res in
            switch res {
            case .success:
                return result(true)
            case .failure(let error):
                return result(error.toFlutterError())
            }
        }
    }

    func changePassword(
        from oldPassword: String,
        to newPassword: String,
        _ result: @escaping FlutterResult
    ) {
        instance.changePassword(from: oldPassword, to: newPassword).start { res in
            switch res {
            case .success:
                return result(true)
            case .failure(let error):
                return result(error.toFlutterError())
            }
        }
    }
}

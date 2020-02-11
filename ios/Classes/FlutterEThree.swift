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
        switch call.method {
        case "getIdentity": getIdentity(result)
        case "hasLocalPrivateKey": hasLocalPrivateKey(result)
        case "register": register(result)
        case "rotatePrivateKey": rotatePrivateKey(result)
        case "cleanUp": cleanUp(result)
        case "findUsers": findUsers(
            try call.getArgument("identities"),
            result
        )
        case "encrypt": encrypt(
            text: try call.getArgument("text"),
            for: call.getOptionalArgument("users"),
            result
        )
        case "decrypt": decrypt(
            text: try call.getArgument("text"),
            from: call.getOptionalArgument("user"),
            result
        )
        case "backupPrivateKey": backupPrivateKey(
            password: try call.getArgument("password"),
            result
        )
        case "resetPrivateKeyBackup": resetPrivateKeyBackup(result)
        case "changePassword": changePassword(
            from: try call.getArgument("oldPassword"),
            to: try call.getArgument("newPassword"),
            result
        )
        case "restorePrivateKey": restorePrivateKey(
            password: try call.getArgument("password"),
            result
        )
        case "unregister": unregister(result)
        case "createGroup": createGroup(
            id: try call.getArgument("groupId"),
            with: try call.getArgument("users"),
            result
        )
        case "loadGroup": loadGroup(
            id: try call.getArgument("groupId"),
            initiator: try call.getArgument("initiator"),
            result
        )
        case "getGroup": getGroup(
            id: try call.getArgument("groupId"),
            result
        )
        case "deleteGroup": deleteGroup(
            id: try call.getArgument("groupId"),
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

    func restorePrivateKey(
        password: String,
        _ result: @escaping FlutterResult
    ) {
        instance.restorePrivateKey(password: password).start { res in
            switch res {
            case .success:
                return result(true)
            case .failure(let error):
                return result(error.toFlutterError())
            }
        }
    }

    func unregister(_ result: @escaping FlutterResult) {
        instance.unregister().start { res in
            switch res {
            case .success:
                return result(true)
            case .failure(let error):
                return result(error.toFlutterError())
            }
        }
    }

    func _registerGroup(
        _ group: Group,
        _ result: @escaping FlutterResult
    ) {
        let uuid = "GROUP:\(UUID().uuidString)"
        groups[uuid] = FlutterGroup(
            origin: instance,
            instance: group,
            channel: self.channel
        )
        return result(uuid)
    }

    func _handleGroupResult(
        _ res: Result<Group, Error>,
        _ result: @escaping FlutterResult
    ) {
        switch res {
        case .success(let group):
            _registerGroup(group, result)
        case .failure(let error):
            return result(error.toFlutterError())
        }
    }

    func createGroup(
        id: String,
        with users: [String: String],
        _ result: @escaping FlutterResult
    ) {
        do {
            let users = try users.mapValues {
                try instance
                    .cardManager
                    .importCard(fromBase64Encoded: $0)
            }

            instance.createGroup(id: id, with: users).start { res in
                self._handleGroupResult(res, result)
            }
        } catch let error {
            return result(error.toFlutterError())
        }
    }

    func loadGroup(
        id: String,
        initiator: String,
        _ result: @escaping FlutterResult
    ) {
        do {
            let card = try instance
                .cardManager
                .importCard(fromBase64Encoded: initiator)

            instance.loadGroup(id: id, initiator: card).start { res in
                self._handleGroupResult(res, result)
            }
        } catch let error {
            return result(error.toFlutterError())
        }
    }

    func getGroup(
        id: String,
        _ result: @escaping FlutterResult
    ) {
        do {
            if let group = try instance.getGroup(id: id) {
                _registerGroup(group, result)
            } else {
                result(FlutterError(
                    code: "group_null",
                    message: "Group is null",
                    details: nil
                ))
            }
        } catch let error {
            return result(error.toFlutterError())
        }
    }

    func deleteGroup(
        id: String,
        _ result: @escaping FlutterResult
    ) {
        instance.deleteGroup(id: id).start { res in
            switch(res) {
            case .success:
                result(true)
            case .failure(let error):
                result(error.toFlutterError())
            }
        }
    }
}

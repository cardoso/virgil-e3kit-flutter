import Flutter
import UIKit

import VirgilE3Kit

// TODO: Remove objects when they're destructed in Flutter
var eThrees: [String: FlutterEThree] = [:]
var groups: [String: FlutterGroup] = [:]

public class SwiftE3kitPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.virgilsecurity.com/e3kit", binaryMessenger: registrar.messenger())
        let instance = SwiftE3kitPlugin(withChannel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    let channel: FlutterMethodChannel

    init(withChannel channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String: Any],
            let instanceId = arguments["_id"] as? String
        else {
            result(FlutterError(
                code: "argument_not_found",
                message: "Could not find argument `_id` of type String",
                details: nil
            ))
            return
        }

        if call.method == "init" {
            guard let identity = arguments["identity"] as? String else {
                result(FlutterError(
                    code: "argument_not_found",
                    message: "Could not find argument `identity` of type String",
                    details: nil
                ))
                return
            }

            do {
                let eThree = try EThree(identity: identity, tokenCallback: { completion in
                    self.channel.invokeMethod("tokenCallback", arguments: ["_id": instanceId], result: { (data: Any) in
                        completion(data as? String, data as? Error)
                    })
                })

                eThrees[instanceId] = FlutterEThree(
                    instance: eThree,
                    channel: self.channel
                )

                result(true)
            } catch let error {
                result(FlutterError(
                    code: "initialize_error",
                    message: "Could not initialize EThree",
                    details: error.localizedDescription
                ))
            }
        }

        do {
            if instanceId.starts(with: "ETHREE:"),
                let eThree = eThrees[instanceId] {
                try eThree.invoke(call, result: result)
            } else if instanceId.starts(with: "GROUP:"),
                let group = groups[instanceId] {
                try group.invoke(call, result: result)
            } else {
                result(FlutterError(
                    code: "not_initialized",
                    message: "Object does not exist",
                    details: nil
                ))
                return
            }
        } catch(let error) {
            result(error)
        }
    }
}

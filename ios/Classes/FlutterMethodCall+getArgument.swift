//
//  FlutterObject.swift
//  e3kit
//
//  Created by Matheus Cardoso on 2/6/20.
//

public extension FlutterMethodCall {
    func getArgument<T>(_ argument: String) throws -> T {
        if let arg = (arguments as? [String: Any])?[argument] as? T {
            return arg
        } else {
            throw FlutterError(
                code: "argument_not_found",
                message: "Could not find argument `\(argument)` of type \(T.self)",
                details: nil
            )
        }
    }

    func getOptionalArgument<T>(_ argument: String) -> T? {
        return try? getArgument(argument)
    }
}

//
//  FlutterError.swift
//  e3kit
//
//  Created by Matheus Cardoso on 11/16/19.
//

import Flutter
import VirgilE3Kit

extension FlutterError: Error {

}

extension Error {
    func toFlutterError() -> FlutterError {
        if let error = self as? EThreeError {
            return error.toFlutterError()
        }

        return FlutterError(
            code: "error",
            message: self.localizedDescription,
            details: nil
        )
    }
}

extension EThreeError {
    func toFlutterError() -> FlutterError {
        switch self {
        case .missingIdentities:
            return FlutterError(
                code: "missing_identities",
                message: localizedDescription,
                details: nil
            )
        case .missingPrivateKey:
            return FlutterError(
                code: "missing_private_key",
                message: localizedDescription,
                details: nil
            )
        case .missingPublicKey:
            return FlutterError(
                code: "missing_public_key",
                message: localizedDescription,
                details: nil
            )
        case .privateKeyExists:
            return FlutterError(
                code: "private_key_exists",
                message: localizedDescription,
                details: nil
            )
        case .strFromDataFailed:
            return FlutterError(
                code: "str_from_data_failed",
                message: localizedDescription,
                details: nil
            )
        case .strToDataFailed:
            return FlutterError(
                code: "str_to_data_failed",
                message: localizedDescription,
                details: nil
            )
        case .userIsAlreadyRegistered:
            return FlutterError(
                code: "user_is_already_registered",
                message: localizedDescription,
                details: nil
            )
        case .userIsNotRegistered:
            return FlutterError(
                code: "user_is_not_registered",
                message: localizedDescription,
                details: nil
            )
        case .verificationFailed:
            return FlutterError(
                code: "verification_failed",
                message: localizedDescription,
                details: nil
            )
        case .verifierInitFailed:
            return FlutterError(
                code: "verifier_init_failed",
                message: localizedDescription,
                details: nil
            )
        case .wrongPassword:
            return FlutterError(
                code: "wrong_password",
                message: localizedDescription,
                details: nil
            )
        }
    }
}

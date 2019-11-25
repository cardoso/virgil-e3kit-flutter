//
//  FlutterError.swift
//  e3kit
//
//  Created by Matheus Cardoso on 11/16/19.
//

import Flutter
import VirgilE3Kit
import VirgilSDK

extension FlutterError: Error {

}

extension Error {
    func toFlutterError() -> FlutterError {
        if let error = self as? EThreeError {
            return error.toFlutterError()
        }

        if let error = self as? CloudKeyStorageError {
            return error.toFlutterError()
        }

        if let error = self as? KeychainStorageError {
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

extension CloudKeyStorageError {
    func toFlutterError() -> FlutterError {
        switch self {
        case .cloudStorageOutOfSync:
            return FlutterError(
                code: "cloud_storage_out_of_sync",
                message: localizedDescription,
                details: nil
            )
        case .entryAlreadyExists:
            return FlutterError(
                code: "entry_already_exists",
                message: localizedDescription,
                details: nil
            )
        case .entryNotFound:
            return FlutterError(
                code: "entry_not_found",
                message: localizedDescription,
                details: nil
            )
        case .entrySavingError:
            return FlutterError(
                code: "entry_saving_error",
                message: localizedDescription,
                details: nil
            )
        }
    }
}

extension KeychainStorageError {
    func toFlutterError() -> FlutterError {
        switch errCode {
        case .creatingAccessControlFailed:
            return FlutterError(
                code: "creating_access_control_failed",
                message: localizedDescription,
                details: nil
            )
        case .emptyKeychainResponse:
            return FlutterError(
                code: "empty_keychain_response",
                message: localizedDescription,
                details: nil
            )
        case .errorParsingKeychainResponse:
            return FlutterError(
                code: "error_parsing_keychain_response",
                message: localizedDescription,
                details: nil
            )
        case .invalidAppBundle:
            return FlutterError(
                code: "invalid_app_bundle",
                message: localizedDescription,
                details: nil
            )
        case .keychainError:
            return FlutterError(
                code: "keychain_error",
                message: localizedDescription,
                details: nil
            )
        case .utf8ConvertingError:
            return FlutterError(
                code: "utf8_converting_error",
                message: localizedDescription,
                details: nil
            )
        case .wrongResponseType:
            return FlutterError(
                code: "wrong_response_type",
                message: localizedDescription,
                details: nil
            )
        }
    }
}

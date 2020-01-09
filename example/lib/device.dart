import 'package:http/http.dart' as http;
import 'package:e3kit/e3kit.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'dart:io' show Platform;

import 'log.dart';

class Device {
  EThree eThree;
  String identity;

  Device(this.identity);

  _log(e) {
    log('[$identity] $e');
  }

  initialize() async {
    final host = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

    //# start of snippet: e3kit_authenticate
    final authCallback = () async {
      final response = (await http.post(
        '$host/authenticate',
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identity': identity})
      )).body;

      return json.decode(response)['authToken'];
    };
    //# end of snippet: e3kit_authenticate

    //# start of snippet: e3kit_jwt_callback
    final tokenCallback = () async { 
      final authToken = await authCallback();

      final response = (await http.get(
        '$host/virgil-jwt',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'}
      )).body;

      return json.decode(response)['virgilToken'];
    };
    //# end of snippet: e3kit_jwt_callback

    try {
      //# start of snippet: e3kit_initialize
      this.eThree = await EThree.init(identity, tokenCallback);
      //# end of snippet: e3kit_initialize
      _log('Initialized');
    } catch(err) {
      _log('Failed initializing: $err');
    }
  }

  EThree getEThree() {
    if (this.eThree == null) {
      throw 'eThree not initialized for $identity';
    }

    return this.eThree;
  }

  register() async {
    final eThree = getEThree();

    try {
      await eThree.cleanUp();
    } catch(err) { }

    try {
      //# start of snippet: e3kit_register
      await eThree.register();
      //# end of snippet: e3kit_register
      _log('Registered');
    } on PlatformException catch(err) { 
      _log('Failed registering: $err'); 
      if (err.code == 'user_is_already_registered') {
          await eThree.rotatePrivateKey();
          _log('Rotated private key instead');
      }
    }
  }

  findUsers(List<String> identities) async {
    final eThree = getEThree();

    try {
      //# start of snippet: e3kit_find_users
      final result = await eThree.findUsers(identities);
      //# end of snippet: e3kit_find_users
      _log('Looked up $identities\'s public key');
      return result;
    } catch(err) {
      _log('Failed looking up $identities\'s public key: $err');
    }
  }

  encrypt(text, [users]) async {
    final eThree = getEThree();

    String encryptedText;

    try {
      //# start of snippet: e3kit_sign_and_encrypt
      encryptedText = await eThree.encrypt(text, users);
      //# end of snippet: e3kit_sign_and_encrypt
      _log('Encrypted and signed: \'$encryptedText\'.');
    } catch(err) {
      _log('Failed encrypting and signing: $err');
    }

    return encryptedText;
  }

  decrypt(text, [String user]) async {
    final eThree = getEThree();

    String decryptedText;

    try {
      //# start of snippet: e3kit_decrypt_and_verify
      decryptedText = await eThree.decrypt(text, user);
      //# end of snippet: e3kit_decrypt_and_verify
      _log('Decrypted and verified: \'$decryptedText');
    } catch(err) {
      _log('Failed decrypting and verifying: $err');
    }

    return decryptedText;
  }

  backupPrivateKey(String password) async {
    final eThree = getEThree();

    try {
      //# start of snippet: e3kit_backup_private_key
      await eThree.backupPrivateKey(password);
      //# end of snippet: e3kit_backup_private_key
      _log('Backed up private key');
    } on PlatformException catch(err) {
      _log('Failed backing up private key: $err');
      if (err.code == 'entry_already_exists') {
        await eThree.resetPrivateKeyBackup();
        _log('Reset private key backup. Trying again...');
        await backupPrivateKey(password);
      }
    }
  }

  changePassword(String oldPassword, String newPassword) async {
    final eThree = getEThree();

    try {
      //# start of snippet: e3kit_change_password
      await eThree.changePassword(oldPassword, newPassword);
      //# end of snippet: e3kit_change_password
      _log('Changed password');
    } on PlatformException catch(err) {
      _log('Failed changing password: $err');
    }
  }

  restorePrivateKey(String password) async {
    final eThree = getEThree();

    try {
      //# start of snippet: e3kit_restore_private_key
      await eThree.restorePrivateKey(password);
      //# end of snippet: e3kit_restore_private_key
      _log('Restored private key');
    } on PlatformException catch(err) {
      _log('Failed restoring private key: $err');
      if (err.code == 'keychain_error') {
        await eThree.cleanUp();
        _log('Cleaned up. Trying again...');
        await restorePrivateKey(password);
      }
    }
  }

  resetPrivateKeyBackup() async {
    final eThree = getEThree();

    try {
      //# start of snippet: e3kit_reset_private_key_backup
      await eThree.resetPrivateKeyBackup();
      //# end of snippet: e3kit_reset_private_key_backup
      _log('Reset private key backup');
    } on PlatformException catch(err) {
      _log('Failed resetting private key backup: $err');
    }
  }

  rotatePrivateKey() async {
    final eThree = getEThree();

    try {
      //# start of snippet: e3kit_rotate_private_key
      await eThree.rotatePrivateKey();
      //# end of snippet: e3kit_rotate_private_key
      _log('Rotated private key');
    } on PlatformException catch(err) {
      _log('Failed rotating private key: $err');
      if (err.code == 'private_key_exists') {
        await eThree.cleanUp();
        _log('Cleaned up. Trying again...');
        await rotatePrivateKey();
      }
    }
  }

  cleanUp() async {
    final eThree = getEThree();

    try {
      //# start of snippet: e3kit_cleanup
      await eThree.cleanUp();
      //# end of snippet: e3kit_cleanup
      _log('Cleaned up');
    } on PlatformException catch(err) {
      _log('Failed cleaning up: $err');
    }
  }

  unregister() async {
    final eThree = getEThree();

    try {
      //# start of snippet: e3kit_unregister
      await eThree.unregister();
      //# end of snippet: e3kit_unregister
      _log('Unregistered');
    } on PlatformException catch(err) {
      _log('Failed unregistering: $err');
    }
  }
}
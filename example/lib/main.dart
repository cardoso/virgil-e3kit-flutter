import 'package:flutter/material.dart';

import 'log.dart';
import 'device.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _logs = '';
  final alice = Device('Alice');
  final bob = Device('Bob');
  
  Map<String, String> aliceFind;
  Map<String, String> bobFind;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  initializeUsers() async {
    await alice.initialize();
    await bob.initialize();
  }

  registerUsers() async {
    await alice.register();
    await bob.register();
  }

  findUsers() async {
    bobFind = await alice.findUsers([bob.identity]);
    aliceFind = await bob.findUsers([alice.identity]);
  }

  encryptAndDecrypt() async {
    final aliceEncryptedText = await alice.encrypt('Hello ${bob.identity}! How are you?', bobFind);
    await bob.decrypt(aliceEncryptedText, aliceFind[alice.identity]);

    final bobEncryptedText = await bob.encrypt('Hello ${alice.identity}! How are you?', aliceFind);
    await alice.decrypt(bobEncryptedText, bobFind[bob.identity]);
  }

  backupPrivateKeys() async {
    await alice.backupPrivateKey('${alice.identity}_pkeypassword');
    await bob.backupPrivateKey('${bob.identity}_pkeypassword');
  }

  changePasswords() async {
    await alice.changePassword('${alice.identity}_pkeypassword',
    '${alice.identity}_pkeypassword_new');
    await bob.changePassword('${bob.identity}_pkeypassword', '${bob.identity}_pkeypassword_new');
  }

  restorePrivateKeys() async {
    await alice.restorePrivateKey('${alice.identity}_pkeypassword_new');
    await bob.restorePrivateKey('${bob.identity}_pkeypassword_new');
  }

  resetPrivateKeyBackups() async {
    await alice.resetPrivateKeyBackup();
    await bob.resetPrivateKeyBackup();
  }

  rotatePrivateKeys() async {
    await alice.rotatePrivateKey();
    await bob.rotatePrivateKey();
  }

  cleanUp() async {
    await alice.cleanUp();
    await bob.cleanUp();
  }

  unregisterUsers() async {
    await alice.unregister();
    await bob.unregister();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    log = (e) {
      if (!mounted) return;
      setState(() { _logs = _logs + '\n' + e; });
    };

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      log('* Testing main methods:');

      log('\n----- EThree.initialize -----');
      await initializeUsers();
      log('\n----- EThree.register -----');
      await registerUsers();
      log('\n----- EThree.findUsers -----');
      await findUsers();
      log('\n----- EThree.encrypt & EThree.decrypt -----');
      await encryptAndDecrypt();

      log('\n* Testing private key backup methods:');

      log('\n----- EThree.backupPrivateKey -----');
      await backupPrivateKeys();
      log('\n----- EThree.changePassword -----');
      await changePasswords();
      log('\n----- EThree.cleanUp -----');
      await cleanUp();
      log('\n----- EThree.restorePrivateKey -----');
      await restorePrivateKeys();
      log('\n----- EThree.resetPrivateKeyBackup -----');
      await resetPrivateKeyBackups();

      log('\n* Testing additional methods:');

      log('\n----- EThree.rotatePrivateKey -----');
      await rotatePrivateKeys();
      log('\n----- EThree.unregister -----');
      await unregisterUsers();
    } catch(err) {
      log('Unexpected error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('E3Kit Flutter Sample'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Text('Running on: $_logs\n'),
          ),
        ),
      ),
    );
  }
}

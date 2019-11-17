import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:e3kit/e3kit.dart';

import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final identity = 'Alice';

      final authCallback = () async {
        final response = (await http.post(
          'http://localhost:3000/authenticate',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'identity': identity})
        )).body;

        return json.decode(response)['authToken'];
      };

      final tokenCallback = () async { 
        final authToken = await authCallback();

        final response =  (await http.get(
          'http://localhost:3000/virgil-jwt',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken'}
        )).body;

        return json.decode(response)['virgilToken'];
      };

      EThree eThree = await EThree.init(identity, tokenCallback);
      platformVersion = await eThree.identity;

      if (await eThree.hasLocalPrivateKey() == false) {
        try {
          await eThree.register();
        } on Exception {
          await eThree.rotatePrivateKey();
        }
      }

      final encrypted = await eThree.encrypt('hello!');
      final decrypted = await eThree.decrypt(encrypted);
      final users = await eThree.findUsers(['Alice']);

      platformVersion = encrypted + ' ' + decrypted + ' ' + users.toString();
    } on PlatformException catch(e) {
      platformVersion = 'Failed to get platform version. $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}

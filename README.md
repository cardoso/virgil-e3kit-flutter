# Virgil E3Kit Flutter (Alpha)

[![Build Status](https://api.travis-ci.com/VirgilSecurity/virgil-e3kit-x.svg?branch=master)](https://travis-ci.com/VirgilSecurity/virgil-e3kit-x)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/VirgilE3Kit.svg)](https://cocoapods.org/pods/VirgilE3Kit)
[![Platform](https://img.shields.io/cocoapods/p/VirgilE3Kit.svg?style=flat)](https://cocoapods.org/pods/VirgilE3Kit)
[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)

[Introduction](#introduction) | [Features](#features) | [Installation](#installation) | [Usage Examples](#usage-examples) | [Samples](#samples) | [License](#license) | [Docs](#docs) | [Support](#support)

## Introduction

<a href="https://developer.virgilsecurity.com/docs"><img width="230px" src="https://cdn.virgilsecurity.com/assets/images/github/logos/virgil-logo-red.png" align="left" hspace="10" vspace="6"></a> [Virgil Security](https://virgilsecurity.com) provides the E3Kit which simplifies work with Virgil Cloud and presents an easy-to-use API for adding a security layer to any application. In a few simple steps you can add end-to-end encryption with multidevice and group channels support.

The E3Kit allows developers to get up and running with Virgil API quickly and add full end-to-end security to their existing digital solutions to become HIPAA and GDPR compliant and more.

## Features

- Strong end-to-end encryption with authorization
- One-to-one and group encryption
- Files and stream encryption
- Recovery features for secret keys
- Strong secret keys storage, integration with Keychain
- Integration with any CPaaS providers like Nexmo, Firebase, Twilio, PubNub, etc.
- Public keys cache features
- Access encrypted data from multiple user devices
- Easy setup and integration into new or existing projects
-  One-to-one channel with perfect forward secrecy using the Double Ratchet algorithm

## About the Flutter implementation

Virgil E3Kit for Flutter is a wrapper of [E3Kit for Swift/Objective-C](https://github.com/VirgilSecurity/virgil-e3kit-x) and [E3Kit for Android](https://github.com/VirgilSecurity/virgil-e3kit-kotlin) done via [Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels). Click the links to see details about the underlying implementations.

## Installation

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  e3kit: "^0.2.7"
```

In your library add the following import:

```dart
import 'package:e3kit/e3kit.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Usage Examples

#### Register user
Use the following lines of code to authenticate user.

```dart
import 'package:e3kit/e3kit.dart';

// initialize E3Kit
final eThree = await EThree.init(identity, tokenCallback);
    
await eThree.register();
```

#### Encrypt & decrypt

Virgil E3Kit lets you use a user's Private Key and their Card to sign, then encrypt text.

```dart
import 'package:e3kit/e3kit.dart';

// TODO: init and register user (see Register User)

// prepare a message
final messageToEncrypt = "Hello, Alice and Den!"

// Search user's Cards to encrypt for
final users = await eThree.findUsers(['Alice', 'Den']);
final encryptedMessage = await eThree.encrypt(messageToEncrypt, users);
```

Decrypt and verify the signed & encrypted data using sender's public key and receiver's private key:

```dart
import 'package:e3kit/e3kit.dart';

// TODO: init and register user (see Register User)

// Find user
final users = await eThree.findUsers(with: [bobUID]);
    
// Decrypt text and verify if it was really written by Bob
final originText = await eThree.decrypt(encryptedText, users[bobUID]);
```

#### Multidevice support

In order to enable multidevice support you need to backup Private Key. It wil be encrypted with [BrainKey](https://github.com/VirgilSecurity/virgil-pythia-x) generated from password and sent to Virgil Cloud.

```swift
ethree.backupPrivateKey(password: userPassword) { error in 
    guard error == nil else {
        // Error handling
    }
    // Private Key successfully backuped
}
```

After the private key is backed up you can use `restorePrivateKey` to load and decrypt the Private Key from virgil cloud.

```swift
ethree.restorePrivateKey(password: userPassword) { error in 
    guard error == nil else {
        // Error handling
    }
    // Private Key successfully restored and saved locally
}
```

## Samples

You can find the sample application here:

| Sample type | 
|----------| 
| [`Basic Sample`](https://github.com/cardoso/virgil-e3kit-flutter/tree/master/example) | 

You can run and study the demo to see how to initialize the SDK, register users and encrypt messages using E3Kit.

## License

This library is released under the [3-clause BSD License](LICENSE).

## Support
Our developer support team is here to help you. Find out more information on our [Help Center](https://help.virgilsecurity.com/).

You can find us on [Twitter](https://twitter.com/VirgilSecurity) or send us email support@VirgilSecurity.com.

Also, get extra help from our support team on [Slack](https://virgilsecurity.com/join-community).

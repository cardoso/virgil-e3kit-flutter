# Virgil E3Kit Flutter (Alpha)

[![Build Status](https://api.travis-ci.com/VirgilSecurity/virgil-e3kit-x.svg?branch=master)](https://travis-ci.com/VirgilSecurity/virgil-e3kit-x)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/VirgilE3Kit.svg)](https://cocoapods.org/pods/VirgilE3Kit)
[![Platform](https://img.shields.io/cocoapods/p/VirgilE3Kit.svg?style=flat)](https://cocoapods.org/pods/VirgilE3Kit)
[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)

[Introduction](#introduction) | [Features](#features) | [Installation](#installation) | [Usage Examples](#usage-examples) | [Enable Group Channel](#enable-group-channel) | [Samples](#samples) | [License](#license) | [Docs](#docs) | [Support](#support)

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

```swift
import VirgilE3Kit

// initialize E3Kit
let eThree = try! EThree(identity: "Bob", tokenCallback: tokenCallback)
    
eThree.register { error in 
    // done
}
```

#### Encrypt & decrypt

Virgil E3Kit lets you use a user's Private key and his or her Card to sign, then encrypt text.

```swift
import VirgilE3Kit

// TODO: init and register user (see Register User)

// prepare a message
let messageToEncrypt = "Hello, Alice and Den!"

// Search user's Cards to encrypt for
eThree!.findUsers(with: ["Alice", "Den"]) { users, error in 
    guard let users = users, error == nil else {
        // Error handling here
    }
    
    // encrypt text
    let encryptedMessage = try! eThree.authEncrypt(text: messageToEncrypt, for: users)
}
```

Decrypt and verify the signed & encrypted data using sender's public key and receiver's private key:

```swift
import VirgilE3Kit

// TODO: init and register user (see Register User)

// Find user
eThree.findUsers(with: [bobUID]) { users, error in
    guard let users = users, error == nil else {
        // Error handling here
    }
    
    // Decrypt text and verify if it was really written by Bob
    let originText = try! eThree.authDecrypt(text: encryptedText, from: users[bobUID]!)
}
```

#### Encrypt & decrypt large files

If the data that needs to be encrypted is too large for your RAM to encrypt all at once, use the following snippets to encrypt and decrypt streams.

Encryption:
```swift
import VirgilE3Kit

// TODO: init and register user (see Register User)
// TODO: Get users UIDs

let usersToEncryptTo = [user1UID, user2UID, user3UID]

// Find users
eThree.findUsers(with: usersToEncryptTo) { users, error in
    guard let users = users, error == nil else {
        // Error handling here
    }

    let fileURL = Bundle.main.url(forResource: "data", withExtension: "txt")!
    let inputStream = InputStream(url: fileURL)!
    let outputStream = OutputStream.toMemory()

    try eThree.authEncrypt(inputStream, to: outputStream, for: users)
}
```

Decryption:
> Stream encryption doesn’t sign the data. This is why decryption doesn’t need Card for verification unlike the general data decryption.
```swift
import VirgilE3Kit

// TODO: init and register user (see Register User)

let outputStream = OutputStream.toMemory()

try eThree.authDecrypt(encryptedStream, to: outputStream)
```

#### Multidevice support

In order to enable multidevice support you need to backup Private Key. It wiil be encrypted with [BrainKey](https://github.com/VirgilSecurity/virgil-pythia-x), generated from password and sent to virgil cloud.

```swift
ethree.backupPrivateKey(password: userPassword) { error in 
    guard error == nil else {
        // Error handling
    }
    // Private Key successfully backuped
}
```

After private key was backuped you can use `restorePrivateKey` method to load and decrypt Private Key from virgil cloud.

```swift
ethree.restorePrivateKey(password: userPassword) { error in 
    guard error == nil else {
        // Error handling
    }
    // Private Key successfully restored and saved locally
}
```

If you authorize users using password in your application, please do not use the same password to backup Private Key, since it breaks e2ee. Instead, you can derive from your user password two different ones.

```swift
let derivedPasswords = try! EThree.derivePasswords(from: userPassword)

// This password should be used for backup/restore PrivateKey
let backupPassword = derivedPasswords.backupPassword
// This password should be used for other purposes, e.g user authorization
let loginPassword = derivedPasswords.loginPassword
```


#### Convinience initializer

`EThree` initializer has plenty of optional parameters to customize it's behaviour. You can easily set them using `EThreeParams` class.

```swift     
    let params = try! EThreeParams(identity: "Alice", 
                                   tokenCallback: tokenCallback)
     
    params.enableRatchet = true
    params.changedKeyDelegate = myDelegate
    
    let ethree = try! EThree(params: params)
```

`EThreeParams` can also be initialized from config plist file.

```swift 
    let configUrl = Bundle.main.url(forResource: "EThreeConfig", withExtension: "plist")!
    
    let params = try! EThreeParams(identity: "Alice", 
                                   tokenCallback: tokenCallback, 
                                   configUrl: configUrl)
    
    let ethree = try! EThree(params: params)
```
The example of config file is [here](https://github.com/VirgilSecurity/virgil-e3kit-x/tree/0.8.0-beta4/Tests/Data/ExampleConfig).

## Enable Group Channel
In this section, you'll find out how to build a group channel using the Virgil E3Kit.

We assume that your users have installed and initialized the E3Kit, and used snippet above to register.


#### Create group channel
Let's imagine Alice wants to start a group channel with Bob and Carol. First, Alice creates a new group ticket by running the `createGroup` feature and the E3Kit stores the ticket on the Virgil Cloud. This ticket holds a shared root key for future group encryption.

Alice has to specify a unique `identifier` of group with length > 10 and `findUsersResult` of participants. We recommend tying this identifier to your unique transport channel id.
```swift 
ethree.createGroup(id: groupId, with: users) { error in 
    guard error == nil else {
        // Error handling
    }
    // Group created and saved locally!
}
```

#### Start group channel session

Now, other participants, Bob and Carol, want to join the Alice's group and have to start the group session by loading the group ticket using the `loadGroup` method. This function requires specifying the group `identifier` and group initiator's Card.
```swift
ethree.loadGroup(id: groupId, initiator: findUsersResult["Alice"]!) { group, error in 
    guard let group = group, error == nil else 
        // Error handling
    }
    // Group loaded and saved locally! 
}
```

Use the loadGroup method to load and save group locally. Then, you can use the getGroup method to retrieve group instance from local storage.
```swift
let group = try! ethree.getGroup(id: groupId)
```

#### Encrypt and decrypt messages
To encrypt and decrypt messages, use the `encrypt` and `decrypt` E3Kit functions, which allows you to work with data and strings.

Use the following code-snippets to encrypt messages:
```swift
// prepare a message
let messageToEncrypt = "Hello, Bob and Carol!"

let encrypted = try! group.encrypt(text: messageToEncrypt)
```

Use the following code-snippets to decrypt messages:
```swift
let decrypted = try! group.decrypt(text: encrypted, from: findUsersResult["Alice"]!)
```
At the decrypt step, you also use `findUsers` method to verify that the message hasn't been tempered with.

### Manage group channel
E3Kit also allows you to perform other operations, like participants management, while you work with group channel. In this version of E3Kit only group initiator can change participants or delete group.

#### Add new participant
To add a new channel member, the channel owner has to use the `add` method and specify the new member's Card. New member will be able to decrypt all previous messages history.
```swift
group.add(participant: users["Den"]!) { error in 
    guard error == nil else {
        // Error handling
    }
    
    // Den was added!
}
```

#### Remove participant
To remove participant, group owner has to use the `remove` method and specify the member's Card. Removed participants won't be able to load or update this group.
```swift
group.remove(participant: users["Den"]!) { error in 
    guard error == nil else {
        // Error handling
    }
    
    // Den was removed!
}
```

#### Update group channel
In the event of changes in your group, i.e. adding a new participant, or deleting an existing one, each group channel participant has to update the encryption key by calling the `update` E3Kit method or reloading Group by `loadGroup`.
```swift
group.update { error in 
    guard error == nil else {
        // Error handling
    }

    // Group updated!
}
```

#### Delete group channel
To delete a group, the owner has to use the `deleteGroup` method and specify the group `identifier`.
```swift

ethree.deleteGroup(id: groupId) { error in
    guard error == nil else {
        // Error handling
    }
    
    // Group was deleted!
}
```

## Double Ratchet Channel
In this section, you'll find out how to create and manage secure channel sessions between two users using the Double Ratchet algorithm so that each message is separately encrypted.

**Double Ratchet** is a session key management algorithm that provides extra secure end-to-end encryption for messaging between two users or endpoints. 
The Double Ratchet algorithm provides perfect forward secrecy and post-compromise security by generating unique session keys for each new message. Even if the communication is somehow compromised, a potential attacker will only be able to access the most recent message, and soon as a new message is sent by one of the two users, the attacker will be locked out again. 

The session keys are generated using a cryptographically strong unidirectional function, which prevents an attacker from potentially obtaining earlier keys derived from later ones. In addition, the parties renegotiate the keys after each message sent or received (using a new key pair unknown to the attacker), which makes it impossible to obtain later keys from earlier ones.

We assume that you have installed and initialized the E3Kit, and your application users are registered using the snippet above.

#### Create channel

To create a peer-to-peer connection using Double Ratchet protocol use the folowing snippet
```swift

ethree.createRatchetChannel(with: users["Bob"]) { channel, error in
    guard error == nil else {
        // Error handling
    }
    // Channel created and saved locally!
}
```

#### Join channel

After someone created channel with user, he can join it

```swift

ethree.joinRatchetChannel(with: users["Alice"]) { channel, error in
    guard error == nil else {
        // Error handling
    }
    // Channel joined and saved locally!
}
```

#### Get channel

After joining or creating channel you can use getRatchetChannel method to retrieve it from local storage.
```swift

let channel = try! ethree.getRatchetChannel(with: users["Alice"])

```

#### Delete channel

Use this snippet to delete channel from local storage and clean cloud invite.

```swift

ethree.deleteRatchetChannel(with: users["Bob"]) { error in
    guard error == nil else {
        // Error handling
    }
    
    // Channel was deleted!
}
```

#### Encrypt and decrypt messages

Use the following code-snippets to encrypt messages:
```swift
// prepare a message
let messageToEncrypt = "Hello, Bob!"

let encrypted = try! channel.encrypt(text: messageToEncrypt)
```

Use the following code-snippets to decrypt messages:
```swift
let decrypted = try! channel.decrypt(text: encrypted)
```

## Unregistered User Encryption
In this section, you'll learn how to create and use temporary channels in order to send encrypted data to users not yet registered on the Virgil Cloud. 

Warning: the temporary channel key used in this method is stored unencrypted and therefore is not as secure as end-to-end encryption, and should be a last resort after exploring the preferred [non-technical solutions](https://help.virgilsecurity.com/en/articles/3314614-how-do-i-encrypt-for-a-user-that-isn-t-registered-yet-with-e3kit).

To set up encrypted communication with unregistered user not yet known by Virgil, the channel creator generates a temporary key pair, saves it unencrypted on Virgil Cloud, and gives access to the identity of the future user. The channel creator uses this key for encryption. Then when the participant registers, he can load this temporary key from Virgil Cloud and use to decrypt messages.

We assume that channel creator has installed and initialized the E3Kit, and used the snippet above to register.

#### Create channel

To create a channel with unregistered user use the folowing snippet
```swift

ethree.createTemporaryChannel(with: "Bob") { channel, error in
    guard error == nil else {
        // Error handling
    }
    // Channel created and saved locally!
}
```

#### Load channel

After user is registered, he can load temporary channel
```swift

ethree.loadTemporaryChannel(asCreator: false, with: "Alice") { channel, error in
    guard error == nil else {
        // Error handling
    }
    // Channel loaded and saved locally!
}
```

If channel creator changes or cleans up their device, he can load temporary channel in simular way
```swift

ethree.loadTemporaryChannel(asCreator: true, with: "Bob") { channel, error in
    guard error == nil else {
        // Error handling
    }
    // Channel loaded and saved locally!
}
```

#### Get channel

After loading or creating channel, you can use getTemporaryChannel method to retrieve it from local storage
```swift

let channel = try! ethree.getTemporaryChannel(with: "Alice")

```

#### Delete channel

Use this snippet to delete channel from local storage and clean cloud invite

```swift

ethree.deleteTemporaryChannel(with: "Bob") { error in
    guard error == nil else {
        // Error handling
    }
    
    // Channel was deleted!
}
```


## Samples

You can find the code samples for Objective-C/Swift here:

| Sample type | 
|----------| 
| [`iOS Demo`](https://github.com/VirgilSecurity/demo-e3kit-ios) | 

You can run the demo to check out the example of how to initialize the SDK, register users and encrypt messages using E3Kit.


## License

This library is released under the [3-clause BSD License](LICENSE).

## Support
Our developer support team is here to help you. Find out more information on our [Help Center](https://help.virgilsecurity.com/).

You can find us on [Twitter](https://twitter.com/VirgilSecurity) or send us email support@VirgilSecurity.com.

Also, get extra help from our support team on [Slack](https://virgilsecurity.com/join-community).

library e3kit;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

part 'src/ethree.dart';
part 'src/group.dart';

typedef RenewJwtCallback = Future<dynamic> Function();
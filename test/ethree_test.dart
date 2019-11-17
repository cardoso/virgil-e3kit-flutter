import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e3kit/e3kit.dart';

void main() {
  const MethodChannel channel = MethodChannel('e3kit');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    EThree eThree = await EThree.init('Bob', () => Future.value('hey'));

    expect(await eThree.identity, 'Bob');
  });
}

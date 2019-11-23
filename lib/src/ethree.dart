part of e3kit;

final _uuid = Uuid();
final _eThrees = Map<String, EThree>();
final MethodChannel _channel =
    const MethodChannel('plugins.virgilsecurity.com/e3kit')
      ..setMethodCallHandler(EThree._handleMethodCall);

class EThree {
  final String _id = _uuid.v4();

  RenewJwtCallback tokenCallback;

  Future<String> get identity async {
    final String version = await _invokeMethod('getIdentity', {});
    return version;
  }

  EThree._(this.tokenCallback) {
    _eThrees[_id] = this;
  }

  static Future<EThree> init(String identity, RenewJwtCallback tokenCallback) async {
    final eThree = EThree._(tokenCallback);
    await eThree._invokeMethod('init', {'identity': identity});
    return eThree;
  }

  Future<bool> hasLocalPrivateKey() {
    return _invokeMethod('hasLocalPrivateKey', {});
  }

  Future<void> register() {
    return _invokeMethod('register', {});
  }

  Future<void> cleanUp() {
    return _invokeMethod('cleanUp', {});
  }

  Future<void> rotatePrivateKey() {
    return _invokeMethod('rotatePrivateKey', {});
  }

  Future<Map<String, String>> findUsers(List<String> identities) {
    Map<String, dynamic> args = {'identities': identities};
    return _invokeMethod('findUsers', args).then((res) => Map<String, String>.from(res));
  }

  Future<String> encrypt(String text, [Map<String, String> users]) {
    return _invokeMethod('encrypt', {'text': text, 'users': users});
  }

  Future<String> decrypt(String text, [String user]) {
    return _invokeMethod('decrypt', {'text': text, 'user': user});
  }

  Future<T> _invokeMethod<T>(String method, [dynamic arguments]) {
    final args = (arguments ?? {});
    args['_id'] = _id;
    return _channel.invokeMethod(method, args);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) {
    final String _id = call.arguments['_id'];

    switch(call.method) {
      case 'tokenCallback':
        return _eThrees[_id].tokenCallback();
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EThree && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
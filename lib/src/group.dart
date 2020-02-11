part of e3kit;

class Group {
  final String _id;

  Group._(this._id);

  Future<String> encrypt(String text) {
    return _invokeMethod('encrypt', {'text': text});
  }

  Future<String> decrypt(String text, [String user]) {
    return _invokeMethod('decrypt', {'text': text, 'user': user});
  }

  Future<void> add(List<String> identities) {
    Map<String, dynamic> args = {'identities': identities};
    return _invokeMethod('add', args).then((res) => Map<String, String>.from(res));
  }

  Future<void> remove(List<String> identities) {
    Map<String, dynamic> args = {'identities': identities};
    return _invokeMethod('remove', args).then((res) => Map<String, String>.from(res));
  }

  Future<void> update() {
    return _invokeMethod('update', {});
  }

  Future<T> _invokeMethod<T>(String method, [dynamic arguments]) {
    final args = (arguments ?? {});
    args['_id'] = _id;
    return _channel.invokeMethod(method, args);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
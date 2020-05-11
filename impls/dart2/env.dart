import 'types.dart';

class Env {
  Env outer;
  Map<String, dynamic> data = {};

  Env(this.outer);

  void set(MalSymbol key, dynamic value) {
    data[key.name] = value;
  }

  dynamic find(MalSymbol key) {
    var value = data[key.name];
    if (value != null) {
      return value;
    }
    if (outer != null) {
      return outer.find(key);
    }
    return null;
  }

  dynamic get(MalSymbol key) {
    var value = find(key);
    if (value == null) {
      throw ('${key.name} not found in environment chain');
    }
    return value;
  }
}

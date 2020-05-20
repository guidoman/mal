import 'dart:math';

import 'types.dart';

class Env {
  Env outer;
  Map<String, dynamic> data = {};

  Env(this.outer);

  Env.withBinds(this.outer, List<MalType> binds, List<dynamic> exprs) {
    if ((binds == null) != (exprs == null)) {
      throw ('binds and exprs must be both set or null');
    }
    if (binds != null) {
      if (binds.length != exprs.length) {
            throw ('binds and exprs not having the same size');
          }
      for (var i = 0; i < binds.length; i++) {
        var key = binds[i];
        if (!(key is MalSymbol)) {
          throw ('invalid bind key $key');
        }
        set(key, exprs[i]);
      }
    }
  }

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

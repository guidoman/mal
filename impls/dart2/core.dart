import 'printer.dart';
import 'types.dart';

Map<MalSymbol, dynamic> ns = {
  MalSymbol('+'): MalBuiltInFunction((List<dynamic> args) {
    return MalNumber(
        (args[0] as MalNumber).value + (args[1] as MalNumber).value);
  }),
  MalSymbol('-'): MalBuiltInFunction((List<dynamic> args) {
    return MalNumber(
        (args[0] as MalNumber).value - (args[1] as MalNumber).value);
  }),
  MalSymbol('*'): MalBuiltInFunction((List<dynamic> args) {
    return MalNumber(
        (args[0] as MalNumber).value * (args[1] as MalNumber).value);
  }),
  MalSymbol('/'): MalBuiltInFunction((List<dynamic> args) {
    return MalNumber(
        (args[0] as MalNumber).value / (args[1] as MalNumber).value);
  }),
  MalSymbol('prn'): MalBuiltInFunction((List<dynamic> args) {
    print(pr_str(args[0]));
    return MalNil();
  }),
  MalSymbol('list'): MalBuiltInFunction((List<dynamic> args) {
    var elements = <MalType>[];
    for (var arg in args) {
      elements.add(arg);
    }
    return MalList(elements);
  }),
  MalSymbol('list?'): MalBuiltInFunction((List<dynamic> args) {
    if (args[0] is MalList) {
      return MalTrue();
    } else {
      return MalFalse();
    }
  }),
  MalSymbol('empty?'): MalBuiltInFunction((List<dynamic> args) {
    var list = args[0] as MalList;
    if (list.elements.length == 0) {
      return MalTrue();
    } else {
      return MalFalse();
    }
  }),
  MalSymbol('count'): MalBuiltInFunction((List<dynamic> args) {
    var arg = args[0];
    if (arg is MalList) {
      return MalNumber(arg.elements.length);
    }
    return MalNumber(0);
  }),
  MalSymbol('='): MalBuiltInFunction(equals),
  MalSymbol('<'): MalBuiltInFunction((List<dynamic> args) {
    if ((args[0] as MalNumber).value < (args[1] as MalNumber).value) {
      return MalTrue();
    } else {
      return MalFalse();
    }
  }),
  MalSymbol('<='): MalBuiltInFunction((List<dynamic> args) {
    if ((args[0] as MalNumber).value <= (args[1] as MalNumber).value) {
      return MalTrue();
    } else {
      return MalFalse();
    }
  }),
  MalSymbol('>'): MalBuiltInFunction((List<dynamic> args) {
    if ((args[0] as MalNumber).value > (args[1] as MalNumber).value) {
      return MalTrue();
    } else {
      return MalFalse();
    }
  }),
  MalSymbol('>='): MalBuiltInFunction((List<dynamic> args) {
    if ((args[0] as MalNumber).value >= (args[1] as MalNumber).value) {
      return MalTrue();
    } else {
      return MalFalse();
    }
  }),
};

MalType _boxBool(bool b) {
  if (b) {
    return MalTrue();
  } else {
    return MalFalse();
  }
}

MalType equals(List<dynamic> args) {
  var l = args[0];
  var r = args[1];
  if (l is MalNumber && r is MalNumber) {
    return _boxBool(l.value == r.value);
  }
  if (l is MalSymbol && r is MalSymbol) {
    return _boxBool(l.name == r.name);
  }
  if ((l is MalNil && r is MalNil) ||
      (l is MalTrue && r is MalTrue) ||
      (l is MalFalse && r is MalFalse)) {
    return MalTrue();
  }
  if (l is MalList && r is MalList) {
    if (l.elements.length != r.elements.length) {
      return MalFalse();
    }
    for (var i = 0; i < l.elements.length; i++) {
      var elemEqual = equals([l.elements[i], r.elements[i]]);
      if (elemEqual is MalFalse) {
        return MalFalse();
      }
    }
    return MalTrue();
  }
  return MalFalse();
}

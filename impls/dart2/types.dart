import 'env.dart';

abstract class MalType {}

class MalList extends MalType {
  List<MalType> elements;

  MalList(this.elements);
}

class MalNumber extends MalType {
  num value;

  MalNumber(this.value);
}

class MalSymbol extends MalType {
  String name;

  MalSymbol(this.name);

  bool operator ==(other) {
    return (other is MalSymbol && other.name == name);
  }

  int get hashCode => name.hashCode;
}

class MalNil extends MalType {}

class MalTrue extends MalType {}

class MalFalse extends MalType {}

class MalFunction extends MalType {
  MalList params;
  MalType ast;
  Env env;
  Function fn;

  MalFunction(this.params, this.ast, this.env) {
    fn = (args) {
      // TODO ???
    };
  }
}

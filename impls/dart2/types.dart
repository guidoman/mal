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
}

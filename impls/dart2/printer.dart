import 'types.dart';

String pr_str(MalType t, {bool print_readably = false}) {
  if (t is MalNumber) {
    return '${t.value}';
  }
  if (t is MalSymbol) {
    var s = t.name;
    if (print_readably) {
      s = s
          .replaceAll('\\', r'\\')
          .replaceAll('\n', r'\n')
          .replaceAll('"', r'\"');
    }
    return s;
  }
  if (t is MalList) {
    var out = <String>[];
    for (var t2 in t.elements) {
      out.add(pr_str(t2, print_readably: print_readably));
    }
    return '(${out.join(" ")})';
  }
  if (t is MalNil) {
    return 'nil';
  }
  if (t is MalTrue) {
    return 'true';
  }
  if (t is MalFalse) {
    return 'false';
  }
  if (t is MalFunction || t is MalBuiltInFunction) {
    return '#<function>';
  }
  throw ('Unsupported Mal type: $t');
}

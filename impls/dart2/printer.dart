import 'types.dart';

String pr_str(MalType t) {
  if (t is MalNumber) {
    return '${t.value}';
  }
  if (t is MalSymbol) {
    return t.name;
  }
  if (t is MalList) {
    var out = <String>[];
    for (var t2 in t.elements) {
      out.add(pr_str(t2));
    }
//    return out.join(' ');
    return '(${out.join(" ")})';
  }
  assert(false, 'Not implemented');
  return '';
}
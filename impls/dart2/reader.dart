import 'malregex.dart';
import 'types.dart';

class Reader {
  int position = 0;
  List<String> tokens;

  Reader(this.tokens);

  String next() {
    if (position >= tokens.length) {
      return null;
    }
    return tokens[position++];
  }

  String peek() {
    if (position >= tokens.length) {
      return null;
    }
    return tokens[position];
  }
}

MalType read_str(String s) {
  var tokens = tokenize(s);
  var reader = Reader(tokens);
  return read_form(reader);
}

MalType read_form(Reader reader) {
  var t = reader.peek();
  if (t[0] == '(') {
    return read_list(reader);
  } else {
    return read_atom(reader);
  }
}

MalList read_list(Reader reader) {
  var t = reader.next();
  assert(t == '(');
  var elements = <MalType>[];
  while (true) {
    t = reader.peek();
    if (t == null) {
      throw ('unbalanced Mal list');
    }
    if (t == ')') {
      reader.next();
      break;
    }
    var form = read_form(reader);
    elements.add(form);
  }
  return MalList(elements);
}

MalType read_atom(Reader reader) {
  // number
  var t = reader.next();
  num n = num.tryParse(t);
  if (n != null) {
    return MalNumber(n);
  }
  // nil
  if (t == 'nil') {
    return MalNil();
  }
  if (t == 'true') {
    return MalTrue();
  }
  if (t == 'false') {
    return MalFalse();
  }
  // symbol
  // Transform input string
  t = t.replaceAll(r'\\', '\\').replaceAll(r'\"', '"').replaceAll(r'\n', '\n');
  return MalSymbol(t);
}

List<String> tokenize(String s) {
  RegExp re = new RegExp(readerPattern);
  List<String> tokens = [];
  for (Match match in re.allMatches(s)) {
    String token = match.group(1);
    if (token.startsWith('"') && !token.endsWith('"')) {
      throw ('unbalanced Mal string: $token');
    }
    if (token != '') {
      tokens.add(token);
    }
  }
  return tokens;
}

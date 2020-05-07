import 'dart:io';

import 'printer.dart';
import 'reader.dart';
import 'types.dart';

MalType READ(String x) {
  return read_str(x);
}

dynamic EVAL(dynamic x) {
  return x;
}

String PRINT(MalType x) {
  return pr_str(x);
}

String rep(String x) {
  return PRINT(EVAL(READ(x)));
}

main() {
  while (true) {
    stdout.write('user> ');
    String input = stdin.readLineSync();
    if (input == null) {
      break;
    }
    try {
      stdout.writeln('${rep(input)}');
    } on Exception catch (e) {
      print(e);
    }
  }
}

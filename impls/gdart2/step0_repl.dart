import 'dart:io';

String READ(String x) {
  return x;
}

String EVAL(String x) {
  return x;
}

String PRINT(String x) {
  return x;
}

String repl(String x) {
  return PRINT(EVAL(READ(x)));
}

main() {
  while (true) {
    stdout.write('user> ');
    String input = stdin.readLineSync();
    if (input == null) {
      break;
    }
    stdout.writeln('${repl(input)}');
  }
}

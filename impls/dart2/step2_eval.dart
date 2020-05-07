import 'dart:io';

import 'printer.dart';
import 'reader.dart';
import 'types.dart';

var repl_env = {
  '+': (MalNumber a, MalNumber  b) => MalNumber(a.value + b.value),
  '-': (MalNumber a, MalNumber  b) => MalNumber(a.value - b.value),
  '*': (MalNumber a, MalNumber  b) => MalNumber(a.value * b.value),
  '/': (MalNumber a, MalNumber  b) => MalNumber(a.value / b.value),
};

dynamic eval_ast(MalType ast, Map<String, dynamic> env)  {
  if (ast is MalSymbol) {
    var value = env[ast.name];
    if (value == null) {
      throw ('could not lookup symbol "${ast.name}"');
    }
    return value;
  } else if (ast is MalList) {
    var evaluatedList = <dynamic>[];
    for (var e in ast.elements) {
      evaluatedList.add(EVAL(e, env));
    }
    return evaluatedList;
  } else {
    return ast;
  }
}

MalType READ(String x) {
  return read_str(x);
}

dynamic EVAL(dynamic ast, Map<String, dynamic> env) {
  if (ast is MalList) {
    if (ast.elements.length == 0) {
      return ast;
    } else {
      var evaluatedList = eval_ast(ast, env);
      return evaluatedList[0](evaluatedList[1], evaluatedList[2]); // TODO varargs
    }
  } else {
    return eval_ast(ast, env);
  }
}

String PRINT(MalType x) {
  return pr_str(x);
}

String rep(String x) {
  return PRINT(EVAL(READ(x), repl_env));
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
    } catch (e) {
      print(e);
    }
  }
}

import 'dart:io';

import 'env.dart';
import 'printer.dart';
import 'reader.dart';
import 'types.dart';

var repl_env = init_repl_env();

Env init_repl_env() {
  var repl_env = Env(null);
  repl_env.set(MalSymbol('+'),
      (MalNumber a, MalNumber b) => MalNumber(a.value + b.value));
  repl_env.set(MalSymbol('-'),
      (MalNumber a, MalNumber b) => MalNumber(a.value - b.value));
  repl_env.set(MalSymbol('*'),
      (MalNumber a, MalNumber b) => MalNumber(a.value * b.value));
  repl_env.set(MalSymbol('/'),
      (MalNumber a, MalNumber b) => MalNumber(a.value / b.value));
  return repl_env;
}

dynamic eval_ast(MalType ast, Env env) {
  if (ast is MalSymbol) {
    var value = env.get(ast);
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

dynamic EVAL(dynamic ast, Env env) {
  if (ast is MalList) {
    var nElems = ast.elements.length;
    if (nElems == 0) {
      return ast;
    } else {
      var firstElement = ast.elements[0];
      // Handle "def!"
      if (firstElement is MalSymbol && firstElement.name == 'def!') {
        if (nElems != 3) {
          throw ('malformed "def!" with $nElems elements');
        }
        var secondElement = ast.elements[1];
        var thirdElement = ast.elements[2];
        if (!(secondElement is MalSymbol)) {
          throw ('expected MalSymbol after "def!", found $secondElement');
        }
        var evaluatedThirdElement = EVAL(thirdElement, env);
        env.set(secondElement, evaluatedThirdElement);
        return evaluatedThirdElement;
      }
      // Handle "let*"
      if (firstElement is MalSymbol && firstElement.name == 'let*') {
        if (nElems != 3) {
          throw ('malformed "let*" with $nElems elements');
        }
        var secondElement = ast.elements[1];
        var newEnv = Env(env);
        if (secondElement is MalList) {
          var elems = secondElement.elements;
          var letEnvSize = elems.length;
          if ((letEnvSize % 2) != 0) {
            throw ('"let*" environment with odd elementes');
          }
          for (var i = 0; i < letEnvSize; i += 2) {
            var symbol = elems[i];
            if (symbol is MalSymbol) {
              var value = EVAL(elems[i + 1], newEnv);
              newEnv.set(symbol, value);
            } else {
              throw ('even element of "let*" environment not a MalSymbol');
            }
          }
        } else {
          throw ('second element of "let*" not a MalList');
        }
        var thirdElement = ast.elements[2];
        return EVAL(thirdElement, newEnv);
      }

      // Apply first element
      var evaluatedList = eval_ast(ast, env);
      return evaluatedList[0](
          evaluatedList[1], evaluatedList[2]); // TODO varargs
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

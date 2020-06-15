import 'dart:io';

import 'core.dart';
import 'env.dart';
import 'printer.dart';
import 'reader.dart';
import 'types.dart';

var repl_env = init_repl_env();

Env init_repl_env() {
  var repl_env = Env(null);
  for (var k in ns.keys) {
    repl_env.set(k, ns[k]);
  }
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
  while (true) {
    // TCO
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
        else if (firstElement is MalSymbol && firstElement.name == 'let*') {
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
          // TCO
          ast = thirdElement;
          env = newEnv;
        }
        // Handle "do"
        else if (firstElement is MalSymbol && firstElement.name == 'do') {
          var restList =
              MalList(ast.elements.sublist(1, ast.elements.length - 1));
          eval_ast(restList, env);
          ast = ast.elements.last; // TCO
        }
        // Handle "if"
        else if (firstElement is MalSymbol && firstElement.name == 'if') {
          if (nElems != 3 && nElems != 4) {
            throw ('if expression invalid size $nElems');
          }
          var secondElement = ast.elements[1];
          var evaluatedCondition = EVAL(secondElement, env);
          if (!(evaluatedCondition is MalNil) &&
              !(evaluatedCondition is MalFalse)) {
            // TCO
            ast = ast.elements[2];
          } else if (nElems == 4) {
            // TCO
            ast = ast.elements[3];
          } else {
            // return nil
            return MalNil();
          }
        }
        // hanlde "fn*"
        else if (firstElement is MalSymbol && firstElement.name == 'fn*') {
          if (nElems != 3) {
            throw ('if expression invalid size $nElems');
          }
          var secondElement = ast.elements[1];
          if (!(secondElement is MalList)) {
            throw ('fn* args not a list');
          }
          MalList args = secondElement;
          return MalFunction(args, ast.elements[2], env);
        }
        // Apply
        else {
          var evaluatedList = eval_ast(ast, env);
          var args = evaluatedList.sublist(1);
          var fn = evaluatedList[0];
          if (fn is MalFunction) {
            // TCO
            ast = fn.ast;
            env = Env.withBinds(fn.env, fn.params.elements, args);
          } else if (fn is MalBuiltInFunction) {
            // build-in function
            return fn.fn(args);
          } else {
            throw ('error applying "${fn}"');
          }
        }
      }
    } else {
      return eval_ast(ast, env);
    }
  }
}

String PRINT(MalType x) {
  return pr_str(x, print_readably: true);
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

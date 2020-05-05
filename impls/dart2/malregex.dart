String singleQuote = '\'';

String readerPattern = r'[\s,]*('
    + r'~@'
    + r'|[\[\]{}()' + singleQuote + r'`~^@]' //
    + r'|"(?:\\.|[^\\"])*"?'
    + r'|;.*'
    + r'|[^\s\[\]{}(' + singleQuote + r'"`,;)]*'
    + r')';
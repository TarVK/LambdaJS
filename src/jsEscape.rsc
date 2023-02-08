module jsEscape

import Lang;

import ParseTree;
import String;
import IO;

public start[Program] jsEscape(start[Program] program) =
    visit(program) {
        case Identifier id => createID(jsEscape("<id>"))
    };

public Identifier createID(str text) = [Identifier]"<text>";

public str jsEscape(str text: /^[0-9]+/) = "_<jsEscapeReplace(text)>";
public str jsEscape(str text: /^(abstract|break|char|debugger|double|export|finally|goto|in|let|null|public|super|throw|try|volatile)$/) = "_<text>";
public str jsEscape(str text: /^(arguments|byte|class|default|else|extends|float|if|instanceof|long|package|return|switch|throws|typeof|while)$/) = "_<text>";
public str jsEscape(str text: /^(await|case|const|delete|enum|false|for|implements|int|native|private|short|synchronized|transient|var|with)$/) = "_<text>";
public str jsEscape(str text: /^(boolean|catch|continue|do|eval|final|function|import|interface|new|protected|static|this|true|void|yield)$/) = "_<text>";
public default str jsEscape(str text) = jsEscapeReplace(text);

public str jsEscapeReplace(str text) = replace(text, (
    "@": "_AT",
    "$": "_$$",
    "_": "__",
    "[": "_LBS",
    "]": "_RBS",
    "(": "_LBR",
    ")": "_RBR",
    "{": "_LBC",
    "}": "_RBC",
    "\<": "_LT",
    "\>": "_GT",
    "=": "_EQ",
    "&": "_AND",
    "|": "_OR",
    "+": "_PLUS",
    "-": "_MIN",
    "*": "_TIMES",
    "/": "_DIV",
    "\\": "_BSLASH",
    "!": "_EXC",
    "%": "_PER",
    "^": "_HAT",
    "#": "_HASH",
    "?": "_QUE",
    ",": "_COMMA",
    ".": "_DOT",
    ":": "_COL",
    ";": "_SEMCOL",
    "\'": "QUOTE",
    "\"": "DQUOTE"
));

str replace(str text, map[str, str] replace) = joinList([char in replace ? replace[char] : char | char <- split("", text)]);
str joinList(list[str] text) = reducer(text, j, "");
str j(str a, str b) = a + b;

str urlEncode(str text) = replace(text, (    
    "@": "%40",
    "$": "%24",
    "_": "%5F",
    "[": "%5B",
    "]": "%5D",
    "(": "%28",
    ")": "%29",
    "{": "%7B",
    "}": "%7D",
    "\<": "%3C",
    "\>": "%3E",
    "&": "%26",
    "|": "%7C",
    "+": "%2B",
    "-": "%2D",
    "*": "%2A",
    "/": "%2F",
    "\\": "%5C",
    "!": "%21",
    "%": "%25",
    "^": "%5E",
    "#": "%23",
    "?": "%3F",
    ",": "%2C",
    ".": "%2E",
    ":": "%3A",
    ";": "%3B",
    "\'": "%27",
    "\"": "%22"
));
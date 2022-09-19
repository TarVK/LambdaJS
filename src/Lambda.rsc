module Lambda


layout Whitespace = [\t-\n\r\ ]*;
lexical Identifier = [a-zA-Z][a-zA-Z0-9]* !>> [a-zA-Z0-9];

start syntax Lambda = bracket "(" Lambda ")"
					| Identifier "=\>" Lambda
					| Identifier
					| Lambda "(" Lambda ")";
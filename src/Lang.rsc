module Lang

layout Whitespace = [\t-\n\r\ ]*;
lexical Identifier = [a-zA-Z][a-zA-Z0-9]* !>> [a-zA-Z0-9];

start syntax Program = Statement*;

lexical StatementEnd = ";";
syntax Statement =  Export
				 > Declaration;

syntax Declaration = Function
				   | Constructor;
syntax Constructor = Identifier+ StatementEnd;
				    
syntax Function = Identifier SimpleStructure* "=" Expression StatementEnd;
syntax SimpleStructure = Identifier
				       | bracket "(" Structure ")";
syntax Structure = Identifier SimpleStructure*; 

syntax SimpleExpression = Identifier 
						| bracket "(" Expression ")"; 
syntax Expression = SimpleExpression+; 

lexical ExportKeyword = "export";
syntax Export = ExportKeyword Expression StatementEnd;
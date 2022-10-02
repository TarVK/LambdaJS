module Lang

layout Whitespace = WhitespaceAndComment*;
lexical WhitespaceAndComment 
    = [\t-\n\r\ ]
    | @category="Comment" "//" ![\n]* $;
    
lexical Identifier = ([a-zA-Z][a-zA-Z0-9]*) \ "output" !>> [a-zA-Z0-9];

start syntax Program = ()Statement*(); // () at start and end, such that the layout is allowed inbetween

lexical StatementEnd = ";";
syntax Statement =  Output
				 > Declaration;

syntax Declaration = Function
				   | Constructor;
syntax Constructor = Identifier+ StatementEnd;
				    
syntax Function = 
    Identifier SimpleStructure+ "=" Expression StatementEnd
    > Identifier "=" Expression StatementEnd;
syntax SimpleStructure = Identifier
				       | bracket "(" Structure ")";
syntax Structure = Identifier SimpleStructure*; 

syntax SimpleExpression = Identifier 
						| bracket "(" Expression ")"; 
syntax Expression = SimpleExpression+; 

lexical OutputKeyword = "output";
syntax Output = OutputKeyword Expression StatementEnd;
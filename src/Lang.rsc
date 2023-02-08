module Lang

layout Whitespace = WhitespaceAndComment* !>> [\t-\n\r\ ] !>> "//";
lexical WhitespaceAndComment 
    = [\t-\n\r\ ]
    | @category="comment" "//" ![\n]* $;
    
// lexical Identifier = [a-zA-Z0-9@$_\[\](){}\<\>&|+\-*/\\!%^#?,.:;\'\"]+ \ "output" !>> [a-zA-Z0-9@$_\[\](){}\<\>&|+\-*/\\!%^#?,.:;\'\"];

lexical Identifier = [a-zA-Z0-9@$_\[\]{}\<\>&|+\-*/\\!%^#?,.:\'\"]+ \ "output" !>> [a-zA-Z0-9@$_\[\]{}\<\>&|+\-*/\\!%^#?,.:\'\"];

start syntax Program = Statement*;

syntax Statement = Output
				 | Declaration;

syntax Declaration = Function
				   | Constructor;
syntax ConstructorName = @category="variable.function" Identifier;
syntax Constructor = ConstructorName Identifier* ";";
				    
syntax Function = Structure "=" Expression ";";
syntax SimpleStructure = @category="variable.parameter" Identifier
				       | bracket "(" Structure ")";
syntax Structure = Identifier SimpleStructure*; 

syntax SimpleExpression = Identifier 
						| bracket "(" Expression ")"; 
syntax Expression = SimpleExpression+; 

syntax Output = "output" Expression ";";
module order

public list[Identifier] getDeclaredVariables(SimpleStructure* args) {
	list[Identifier] variables = [];
	visit (args) {
		
	}
	return variables;
}
public list[Identifier] getFreeVariables(Expression exp) {
	list[Identifier] dependencies = [];
	visit (exp) {
		case (Expression)`<Identifier name>`: 
			dependencies += name;
		case (Expression)`[<SimpleStructure* args> =\> <Expression subExp>]`: 
			dependencies += (getFreeVariables(subExp) | it - getDeclaredVariables(arg) | SimpleStructure arg <- args); 
	}
	return dependencies;
}
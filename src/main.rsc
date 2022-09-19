module main
import Lang;
import IO;
import String;
import Node;
import ParseTree;
import abstractData;
import IO;
import matchPattern;

public Program parse(str txt) = parse(#Program, txt);

public list[Const] getConstructors(Program program) {
	list[Const] out = [];
	visit (program) {
		case (Declaration)`<Constructor const>`: {
			if((Constructor)`<Identifier+ parts>;` := const){
				list[Identifier] partsList = [p | Identifier p <- parts];
				out += Const(asStr(head(partsList)), size(partsList)-1, const);
			}
		}
	}
	return out;
}
public list[SubstitutedMatchList] tes(Program program) {
	list[SubstitutedMatchList] out = [];
	list[Const] constructors = getConstructors(program);
	visit (program) {
		case (Declaration)`<Identifier name> <SimpleStructure* args> = <Expression body>;`: {
			out += <createMatchList(constructors, 0, End(), [ss | SimpleStructure ss <- args]), (), body, false>;
		}
	}
	return out;
} 

public str getPatternText(str name, int paramCount, list[int] path) = "<name>(<
	("" | it + ",<path + item>" | item <- [0..paramCount])[1..]
>)";


public void printSplit(ST(exp, subs), str begin, str dent) { 
	println("<begin><exp>/<subs>");
}
public void printSplit(Undefined(), str begin, str dent) { 
	println("<begin> Undefined");
}
public void printSplit(Split(path, matchers, rest), str begin, str dent) {
 	println("<begin>split on <path>{");
 	for(const <- matchers) {
 		if(Const(name, paramCount, _) := const) {
 			printSplit(matchers[const], "<dent>  <getPatternText(name, paramCount, path)>: ", dent+"  ");
 		}
 	}
 	printSplit(rest, "<dent>  default: ", dent+"  ");
	println("<dent>}");
}


str toParam([int pos, *rest]) = "$<pos><toParam(rest)>";
str toParam([]) = "";
public str substitute(Substitution sub, (Expression)`<SimpleExpression+ exps>`) 
	= "<for(exp <- exps){><substitute(sub, exp)> <}>";
public str substitute(Substitution sub, (SimpleExpression)`(<Expression exp>)`) 
	= "(<substitute(sub, exp)>)";
public str substitute(Substitution sub, (SimpleExpression)`<Identifier id>`) {
	str idText = "<id>";
	if(idText in sub) return toParam(sub[idText]);
	return idText;
}

//innermost visit (exp) {
//	case (SimpleExpression)`<Identifier id>` => {
//		//if(id in sub) {
//		//	x = toParam(sub[id]);
//		//	return (SimpleExpression)`<Identifier x>`;
//		//}
//		return (SimpleExpression) `<Identifier id>`;
//	}
//};
public void printLines(str text) {
	for(/^<word: \w+>$/m := text) println(word);
} 


public str getLambda(ST(exp, subs), str dent, list[Const] constructors) 
	="<substitute(subs, exp)>\n";
public str getLambda(Undefined(), str dent, list[Const] constructors)  
	= "undefined\n";
public str getLambda(Param(path, next), str dent, list[Const] constructors)  
	= "<toParam(path)>=\><getLambda(next, dent, constructors)>";
public str getLambda(Split(path, matchers, rest), str dent, list[Const] constructors) {
 	str param = toParam(path); 	
 	str out = param;
 	for(const <- constructors, Const(_, paramCount, _) := const) {
 		out += " (\n";
 		out += dent + ("  " | it + "<toParam(path + item)>=\>" | item <- [0..paramCount]);
 		if(const in matchers)
 			out += getLambda(matchers[const], dent+"    ", constructors);
 		else 
 			out += getLambda(rest, dent+"    ", constructors);
 		out += dent + ")";
 	} 
 	return out + "\n";
}
	
public void test2(Program program) {
	list[SubstitutedMatchList] matches = tes(program);	
	list[Const] constructors = getConstructors(program);
	MatchTree Split = createMatchTree(constructors, matches, [0], []);
	println(getLambda(Split, "", constructors));
	//printLines(getLambda(Split, "", constructors));
}
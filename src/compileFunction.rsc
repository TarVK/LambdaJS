module compileFunction
import Lang;
import abstractData;
import List;


public str compileFunction(Undefined(), list[Const] constructors)
    = "Undefined(_)";
public str compileFunction(ST(expression, substitution), list[Const] constructors)
    = lazyLambdaExpression(expression, substitution);
public str compileFunction(Param(paramPath, rest), list[Const] constructors)
    = "<toParam(paramPath)>=\><compileFunction(rest, constructors)>";
public str compileFunction(Split(splitPath, matchers, rest), list[Const] constructors) {
    str param = toParam(splitPath);  
    str out = "<param>(_)";
    for(const <- constructors, Const(_, paramCount, _) := const) {
        out += "(";
        out += ("_=\>" | it + "<toParam(splitPath + item)>=\>" | item <- [0..paramCount]);
        if(const in matchers)
            out += compileFunction(matchers[const], constructors);
        else 
            out += compileFunction(rest, constructors);
        out += ")";
    } 
    return out;
}

// Get the lazy lambda expression representation of a function
public str lazyLambdaExpression((Expression)`<SimpleExpression+ subExpressions>`, Substitution substitution) {
    list[SimpleExpression] parts = [s | s <- subExpressions];
    SimpleExpression first = head(parts);
    return lazyLambdaExpression(first, substitution) + lazyLambdaExpression(tail(parts), substitution);
} 

public str lazyLambdaExpression([first, *rest], Substitution substitution)
    = "(_=\><lazyLambdaExpression(first, substitution)>)" + lazyLambdaExpression(rest, substitution);
public str lazyLambdaExpression([], Substitution substitution)
    = "";
    
public str lazyLambdaExpression((SimpleExpression)`<Identifier id>`, Substitution substitution)
    = "<getIdentifier(id, substitution)>(_)";    
str lazyLambdaExpression((SimpleExpression)`(<Expression expression>)`, Substitution substitution)
    = "(<lazyLambdaExpression(expression, substitution)>)";
    
// Some helper functions
str getIdentifier(Identifier id, Substitution substitution) {
    str strID = "<id>";
    if (strID in substitution) return toParam(substitution[strID]);
    else return strID;
}

str toParam([int pos, *rest]) = "$<pos><toParam(rest)>";
str toParam([]) = "";
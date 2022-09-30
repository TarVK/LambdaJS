module lambdaHelpers
import Map;
import List;

public data DefinitionGroup = DG(
    bool recurses,
    map[str, str] definitions
);
public str combineDefinitions(list[DefinitionGroup] definitionGroups, str out) {
    for (DG(recurses, definitions) <- reverse(definitionGroups)) {
        int d = size(definitions);
        if (!recurses) d = 0;
        
        str wrap = "$D<d>(_)";
        for (defName <- definitions) 
            wrap += "(_=\><getDefinitionParams(definitions, recurses)><definitions[defName]>)";
        wrap += "(_=\><getDefinitionParams(definitions, true)><out>)";
        out = wrap;
    }
    return out;
}
public str getDefinitionParams(map[str, str] definitions, bool recurses) {
    if (recurses) return ("" | it + "<name>=\>" | name <- definitions);
    return "";
}

// Provides a given expression body with the required helpers
public str wrapHelpers(str body, set[int] requiredDefiners) {
    str out = body;
    for (funcCount <- requiredDefiners) 
        out = "($D<funcCount>=\><out>)(<createDefiner(funcCount)>)";
    out = "($Y=\><out>)(<Y>)";
    out = "(_=\><out>)(_=\>_)";
    return out;
}

public str Y = "_=\>f=\>(x=\>f(_)(_=\>x(x)))(x=\>f(_)(_=\>x(x)))";

// A "definer" is a lambda function for defining recursive functions that can be called from within other functions/expressions
public str createDefiner(int recursiveFuncCount) {
    // Hardcode 0, because there's no recursion
    if (recursiveFuncCount==0)
        return "_=\>$0=\>c=\>c(_)($0)";
    // Hardcode 1, because there's no required tupling
    if (recursiveFuncCount==0)
        return "_=\>$0=\>c=\>(f=\>c(_)(f))(_=\>$Y(_)($0))";
    
    int c = recursiveFuncCount;
    // Define the input function constructor and continuation function parameters
    str out = "_=\><defineParams(c)>c=\>";
    // Call the continuation, given the recursive function
    out += "(f=\>c(_)";
    for (i <- [0..c]) 
        out += "(_=\>f(_)(<defineParams("s", c)>$s<i>))";
    out += ")";
    // Create recursive functions to provide
    out += "(_=\>$Y(_)(_=\>r=\>(";
    out += defineParams("r", c)+"g=\>g(_)";
    for (i <- [0..c])
        out += "(_=\>$<i>(_)<applyArgs("r", c)>)";
    out += ")";
    for (i <- [0..c])
        out += "(_=\>r(_)(<defineParams("s", c)>$s<i>))";
    out += "))";
    
    return out;
}

// defineParams("s", 2) == "$s0=>$s1=>"
public str defineParams(int i) = defineParams("", i);
public str defineParams(str prefix, int i){
    if (i>0) return "<defineParams(prefix, i-1)>$<prefix><i-1>=\>";
    return "";
} 

// applyArgs("s", 2) == "($s0)($s1)"
public str applyArgs(int i) = applyArgs("", i);
public str applyArgs(str prefix, int i) {
    if (i>0) return "<applyArgs(prefix, i-1)>($<prefix><i-1>)";
    return "";
}
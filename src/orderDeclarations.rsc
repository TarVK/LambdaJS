module orderDeclarations
import Lang;
import List;
import Set;
import abstractData;
import IO;

// Retrieving dependencies
alias Dependencies = map[str, set[Identifier]];

public Dependencies dependencies(map[str, list[Function]] functions, set[str] constructors) 
    = dependencies(functions, constructors, true);
public Dependencies dependencies(map[str, list[Function]] functions, set[str] constructors, bool includePattern) 
    = (name: dependencies(functions[name], constructors, includePattern) | name <- functions);
    
public set[Identifier] dependencies([Function function, *rest], set[str] constructors, bool includePattern)
     = dependencies(function, constructors, includePattern) + dependencies(rest, constructors, includePattern);
public set[Identifier] dependencies([], set[str] constructors, bool includePattern)
    = {};
    
public set[Identifier] dependencies(
    (Function)`<Structure structure> = <Expression body>;`, 
    set[str] constructors, 
    bool includePattern
) {
    if((Structure)`<Identifier name><SimpleStructure* paramStructures>` := structure) {
        set[Identifier] references = dependencies(body);
        if(includePattern) references += dependencies(structure);
        set[str] params = parameters([s | s <- paramStructures], constructors);
        return {r | r <- references, !("<r>" in params)};
    }
    return {};
}

// Note, this does not correctly retrieve all simple structure constructor dependencies
public set[Identifier] dependencies((Expression)`<SimpleExpression+ ss>`)
    = dependencies([s | s <- ss]);
public set[Identifier] dependencies([(SimpleExpression)`<Identifier id>`, *rest]) 
    = {id} + dependencies(rest);
public set[Identifier] dependencies([(SimpleExpression)`(<Expression exp>)`, *rest])
    = dependencies(exp) + dependencies(rest);
public set[Identifier] dependencies((Structure)`<Identifier id> <SimpleStructure* ss>`) 
    = {id} + dependencies([s | s <- ss]);
public set[Identifier] dependencies([(SimpleStructure)`<Identifier id>`, *rest])
    = dependencies(rest);
public set[Identifier] dependencies([(SimpleStructure)`(<Structure substructure>)`, *rest])
    = dependencies(substructure) + dependencies(rest);
public set[Identifier] dependencies([])
    = {};
    
public set[str] parameters((Structure)`<Identifier const> <SimpleStructure* ss>`, set[str] constructors) {
    set[str] params = parameters([s | s <- ss], constructors);
    if (!("<const>" in constructors) && size(params) == 0) return {"<const>"};
    return params; 
} 
public set[str] parameters([(SimpleStructure)`<Identifier id>`, *rest], set[str] constructors)
    = {"<id>"} + parameters(rest, constructors);
public set[str] parameters([(SimpleStructure)`(<Structure substructure>)`, *rest], set[str] constructors)
    = parameters(substructure, constructors) + parameters(rest, constructors);
public set[str] parameters([], set[str] constructors)
    = {};
    
// Create strongly connected components in the right order, adapted from: https://www.geeksforgeeks.org/strongly-connected-components/
alias StringDependencies = map[str, set[str]];
StringDependencies stringDependencies(Dependencies dependencies)
    = (name: stringDependencies(dependencies[name]) | name <- dependencies);
set[str] stringDependencies({Identifier dependency, *rest}) 
    = {"<dependency>"} + stringDependencies(rest);
set[str] stringDependencies({}) 
    = {};    

StringDependencies getTranspose(StringDependencies dependencies) {
    StringDependencies out = (v: {} | v <- dependencies);
    for(str funcName <- dependencies)
        for(str dependency <- dependencies[funcName])
            if (dependency in out)
                out[dependency] += funcName;
    return out;     
}
data OrderData = OD(
    set[str] visited,
    list[str] out
);
OrderData postOrder(StringDependencies dependencies, str funcName, set[str] visited) {
    visited += funcName;
    list[str] out = [];
    for (neighbor <- dependencies[funcName])
        if (!(neighbor in visited) && neighbor in dependencies) 
            if (OD(newVisited, newOut) := postOrder(dependencies, neighbor, visited)) {
                visited += newVisited;
                out += newOut;
            }
    out += funcName;
    return OD(visited, out);
}
list[set[str]] getSCC(StringDependencies dependencies) {
    list[str] stack = [];
    set[str] visited = {};
    
    for (funcName <- dependencies)
        if (!(funcName in visited))
            if (OD(newVisited, newStack) := postOrder(dependencies, funcName, visited)) {
                stack += newStack;
                visited += newVisited;
            }
            
    StringDependencies reversedDependencies = getTranspose(dependencies);
    set[str] visited2 = {};
    list[set[str]] components = [];
    for (funcName <- reverse(stack)) 
        if (!(funcName in visited2)) 
            if (OD(newVisited, component) := postOrder(reversedDependencies, funcName, visited2)) {
                components += toSet(component);
                visited2 += newVisited;
            }
    return reverse(components);
}


// Create an order with recursion data
public Errors getUnknownFunctions(Dependencies dependencies, set[str] funcs)
    = {*getUnknownFunctions(dependencies[name], funcs) | name <- dependencies};
public Errors getUnknownFunctions({Identifier dependency, *rest}, set[str] funcs) {
    if ("<dependency>" in funcs) return getUnknownFunctions(rest, funcs);
    else return UnknownIdentifier(dependency) + getUnknownFunctions(rest, funcs);   
} 
public Errors getUnknownFunctions({}, set[str] funcs) 
    = {};   

public alias FunctionOrder = list[FunctionGroup];
public data FunctionGroup = FG(
    bool recurses,
    set[str] functions
);

public WithErrors[FunctionOrder] orderDeclarations(map[str, list[Function]] functions,  map[str, Const] constructors) {
    set[str] constNames = {c | c <- constructors};
    Dependencies d = dependencies(functions, constNames);
    StringDependencies sd = stringDependencies(d);
    list[set[str]] components = getSCC(sd);
    return <
        [FG(size(component) > 1 || (v in sd[v]), component) | component <- components, v := getOneFrom(component)],
        getUnknownFunctions(dependencies(functions, constNames, false), {f | f <- functions} + constNames)
    >;
}

public Errors getUnknownInExpression(Expression exp, map[str, list[Function]] functions,  map[str, Const] constructors) {
    set[str] constNames = {c | c <- constructors};
    return getUnknownFunctions(dependencies(exp), {f | f <- functions} + constNames);
}
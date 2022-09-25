module orderDeclarations
import Lang;
import List;
import Set;

// Retrieving dependencies
alias Dependencies = map[str, set[str]];

public Dependencies dependencies(map[str, list[Function]] functions) 
    = (name: dependencies(functions[name]) | name <- functions);
    
public set[str] dependencies([Function function, *rest])
     = dependencies(function) + dependencies(rest);
public set[str] dependencies([])
    = {};
    
public set[str] dependencies((Function)`<Identifier _> <SimpleStructure* params> = <Expression body>;`) 
    = dependencies(body) + dependencies([s | s <- params]) - parameters([s | s <- params]);

public set[str] dependencies((Expression)`<SimpleExpression+ ss>`)
    = dependencies([s | s <- ss]);
public set[str] dependencies([(SimpleExpression)`<Identifier id>`, *rest]) 
    = {"<id>"} + dependencies(rest);
public set[str] dependencies([(SimpleExpression)`(<Expression exp>)`, *rest])
    = dependencies(exp) + dependencies(rest);
public set[str] dependencies((Structure)`<Identifier id> <SimpleStructure* ss>`) 
    = {"<id>"} + dependencies([s | s <- ss]);
public set[str] dependencies([(SimpleStructure)`<Identifier id>`, *rest])
    = dependencies(rest);
public set[str] dependencies([(SimpleStructure)`(<Structure substructure>)`, *rest])
    = dependencies(substructure) + dependencies(rest);
    
public set[str] parameters((Structure)`<Identifier _> <SimpleStructure* ss>`) 
    = parameters([s | s <- ss]);
public set[str] parameters([(SimpleStructure)`<Identifier id>`, *rest])
    = {"<id>"} + parameters(rest);
public set[str] parameters([(SimpleStructure)`(<Structure substructure>)`, *rest])
    = parameters(substructure) + parameters(rest);
public set[str] parameters([])
    = {};
    
// Create strongly connected components in the right order, adapted from: https://www.geeksforgeeks.org/strongly-connected-components/
Dependencies getTranspose(Dependencies dependencies) {
    Dependencies out = (v: {} | v <- dependencies);
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
OrderData postOrder(Dependencies dependencies, str funcName, set[str] visited) {
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
list[set[str]] getSCC(Dependencies dependencies) {
    list[str] stack = [];
    set[str] visited = {};
    
    for (funcName <- dependencies)
        if (!(funcName in visited))
            if (OD(newVisited, newStack) := postOrder(dependencies, funcName, visited)) {
                stack += newStack;
                visited += newVisited;
            }
            
    Dependencies reversedDependencies = getTranspose(dependencies);
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
public alias FunctionOrder = list[FunctionGroup];
public data FunctionGroup = FG(
    bool recurses,
    set[str] functions
);

public FunctionOrder orderDeclarations(map[str, list[Function]] functions) {
    // TODO: add error handling by detecting non-declared functions
    Dependencies d = dependencies(functions);
    list[set[str]] components = getSCC(d);
    return [FG(size(component) > 1 || (v in d[v]), component) | component <- components, v := getOneFrom(component)];
}
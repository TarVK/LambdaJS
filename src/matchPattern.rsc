module matchPattern
import Lang;
import util::Maybe;
import List;
import IO;
import util::Math;
import abstractData;

// Create a matchList from the Structure CST, to simplify matching
data MatchList = Match(
    int depth,
    Const match,
    MatchList rest,
    Structure structure
) | Variable(
     int depth,
     str name,
     MatchList rest,
     Identifier variable 
) | End(
    Function func,
    Expression expression
);
data MatchListOrError = ML(MatchList ml) | E(Error);

str asStr(Match(depth, Const(name, _, _), rest, _)) {
    str restStr = asStr(rest);
    return "[<depth>: <name>] -\> <restStr>";
}
str asStr(Variable(depth, name, rest, _)) {
    str restStr = asStr(rest);
    return "[<depth>: <name>] -\> <restStr>";
}
str asStr(End(_, _)) = "null";


public MatchListOrError createMatchList(
    list[Const] constructors,
    Function function
) {
    if((Function)`<Identifier name> <SimpleStructure* args> = <Expression body>;` := function) {
        MatchList end = End(function, body);
        return createMatchList(constructors, 0, end, [ss | SimpleStructure ss <- args]);
    }
    throw "error, shouldn\'t be reachable";
}
public MatchListOrError createMatchList(list[Const] constructors, int depth, MatchList next, value val) {
    switch (val) {
        case (Structure)`<Identifier const> <SimpleStructure* params>`: {
            list[SimpleStructure] paramList = [ss | SimpleStructure ss <- params];
            if (just(constructor) := findConstructor(constructors, "<const>")) {
                MatchListOrError newNext = createMatchList(constructors, depth+1, next, paramList);
                if (ML(next) := newNext) return ML(Match(depth, constructor, next, val));
                return newNext;
            }
            
            if(size(paramList)==0)
                return ML(Variable(depth, "<const>", next, const));
                    
            return E(UnknownConstructor(const));
        } 
        case [(SimpleStructure)`<Identifier first>`, *rest]: {
            if (just(constructor) := findConstructor(constructors, "<first>")) {
                MatchListOrError newNext = createMatchList(constructors, depth, next, rest);
                if (ML(next) := newNext) return ML(Match(depth, constructor, next, (Structure)`<Identifier first>`));
                return newNext;
            }
                
            MatchListOrError newNext = createMatchList(constructors, depth, next, rest);
            if (ML(next) := newNext) return ML(Variable(depth, "<first>", next, first));
            return newNext;
        }
        case [(SimpleStructure)`(<Structure substructure>)`, *rest]: {
            MatchListOrError newNext = createMatchList(constructors, depth, next, rest);
            if (ML(next) := newNext) return createMatchList(constructors, depth, next, substructure);
            return newNext;
        }
    }
    return ML(next);
}
    
public Maybe[Const] findConstructor([Const first, *rest], str name) {
    if (Const(name, _, _) := first) return just(first);
    else return findConstructor(rest, name);
}
public Maybe[Const] findConstructor([], str name) = nothing();

// Create an abstract match tree 
alias SubstitutedMatchList = tuple[MatchList, Substitution,  OnHold];


public int getDepth(<Match(depth, _, _, _), _, _>) = depth;
public int getDepth(<Variable(depth, _, _, _), _, _>) = depth;
public int getDepth(<End(_, _), _, _>) = -1; 

//test example:
//m (Node left (Leaf val)) (Leaf val2) = 1;
//m (Node (Leaf val) right) (Leaf val2) = 2;
//m (Node left right) val = 3;
//m (Node left right) = 4;
//m node (Node left right) = 5;
//
//1; 0:Node, 1:left, 1:Leaf, 2:val, 0:Leaf, 1:val2, -1
//2; 0:Node, 1:Leaf, 2:val, 1:right, 0:Leaf, 1:val2, -1
//3; 0:Node, 1:left, 1:right, 0:val, -1
//4; 0:Node, 1:left, -1
//5; 0:node, 0:Node, 1:left, 1:right, -1

public Maybe[SubstitutedMatchList] constNext(<MatchList ml, Substitution sub, true>, list[int] param, Const const) 
    = just(<ml, sub, true>); 
public Maybe[SubstitutedMatchList] constNext(<Match(_, c, next, _), Substitution sub, false>, list[int] param, Const const) {
    if(const == c) return just(<next, sub, false>);
    else return nothing();
}   
public Maybe[SubstitutedMatchList] constNext(<Variable(_, name, next, _), Substitution sub, false>, list[int] param, Const const) 
    = just(<next, sub + (name: param), true>);
public Maybe[SubstitutedMatchList] constNext(<End(func, exp), Substitution sub, false>, list[int] param, Const const) 
    = just(<End(func, exp), sub, false>);
    
    
public Maybe[SubstitutedMatchList] restNext(<MatchList ml, Substitution sub, true>, list[int] param) 
    = just(<ml, sub, true>); 
public Maybe[SubstitutedMatchList] restNext(<Match(_, _, _, _), Substitution sub, false>, list[int] param) 
    = nothing();
public Maybe[SubstitutedMatchList] restNext(<Variable(_, name, next, _), Substitution sub, false>, list[int] param) 
    = just(<next, sub + (name: param), false>);
public Maybe[SubstitutedMatchList] restNext(<End(func, exp), Substitution sub, false>, list[int] param) 
    = just(<End(func, exp), sub, false>);

public WithErrors[MatchTree] createMatchTree(
    list[Const] constructors, 
    list[SubstitutedMatchList] matches
) = createMatchTree(constructors, matches, [0], []);
public WithErrors[MatchTree] createMatchTree(
    list[Const] constructors, 
    list[SubstitutedMatchList] matches, 
    list[int] pos, 
    list[Const] constPath
) {
    int depth = size(pos)-1;
    Errors errors = {};
    
    // Check constructor argument counts
    list[SubstitutedMatchList] tooFewArgs = [m | m <- matches, <Match(_, const, _, struct), _, _> := m && hasFewerArgs(struct, const)];
    matches -= tooFewArgs;
    errors += {TooFewArguments(const, s) | <Match(_, const, _, s), _, _><-tooFewArgs};
    
    list[SubstitutedMatchList] tooManyArgs = [m | m <- matches, <Match(_, const, _, struct), _, _> := m && hasMoreArgs(struct, const)];
    matches -= tooManyArgs;
    errors += {TooManyArguments(const, s) | <Match(_, const, _, s), _, _><-tooManyArgs};
    
    // Finish constructor if end of constructor
    if (
        [*constPathStart, const] := constPath 
        && Const(_, paramCount, _) := const 
        && [*posStart, int prevIndex, int index] := pos 
        && index >= paramCount
    ) {        
        int newDepth = depth-1;
        list[SubstitutedMatchList] newMatches = 
            [<m, sub, (onHold && getDepth(ml) < newDepth)> | ml <- matches, <m, sub, onHold> := ml];
        
        if(<result, newErrors> := createMatchTree(constructors, newMatches, posStart + (prevIndex+1), constPathStart))
            return <result, newErrors + errors>;
    }
    
    // Finish if the first match is an end
    if (depth == 0) {
        if([<End(_, exp), Substitution sub, _>, *r] := matches)
            return <ST(exp, sub), errors>;
        if (size(matches) == 0) 
            return <Undefined(), errors>; 
    }
    
    // Split the tree    
    list[Const] applicableConstructors = 
        [constructor | constructor <- constructors, size([c | <Match(d, c, _, _), _, _> <- matches, c == constructor && d == depth])>0];
    map[Const, MatchTree] patternMatchesMap = (
        constructor: {
            list[SubstitutedMatchList] constMatches = [k | m <- matches, just(k) := constNext(m, pos, constructor)];
            MatchTree tree;
            if(<result, newErrors> := createMatchTree(
                constructors,
                constMatches,
                pos + 0,
                constPath + constructor
            )){
                errors += newErrors;
                tree = result;
            } 
            tree;
        } | constructor <- applicableConstructors);


    list[int] nextPos = [];
    if ([*begin, int last] := pos) nextPos = begin + (last + 1);
    list[SubstitutedMatchList] restMatches = [k | m <- matches, just(k) := restNext(m, pos)];
    MatchTree restTree;
    if(<result, newErrors> := createMatchTree(
        constructors,
        restMatches,
        nextPos,
        constPath
    )) {
        restTree = result;
        errors += newErrors;
    }
    
    MatchTree returnTree = restTree;  
    if (size(applicableConstructors)>0) {
        returnTree = Split(pos, patternMatchesMap, restTree);
        
        // Check whether there are too few arguments
        if (depth==0) {
            list[SubstitutedMatchList] finished = [m | m <- matches, getDepth(m) == -1];
            list[SubstitutedMatchList] notFinished = [m | m <- matches, getDepth(m) > -1];
            if(size(finished) > 0)
                errors += {TooFewParameters(getStructures(notFinished), getStructure(ml)) | ml<-finished};
        }
    }
    if (depth==0) returnTree = Param(pos, returnTree);
    
    return <returnTree, errors>;
}



// Error handling types
bool hasMoreArgs((Structure)`<Identifier _> <SimpleStructure* s>`, Const(_, paramCount, _)) = size([k | k <- s]) > paramCount;
bool hasFewerArgs((Structure)`<Identifier _> <SimpleStructure* s>`, Const(_, paramCount, _)) = size([k | k <- s]) < paramCount; 

Structure getStructure(<Match(_, _, next, _), x, y>) = getStructure(<next, x, y>);
Structure getStructure(<Variable(_, _, next, _), x, y>) = getStructure(<next, x, y>);
Structure getStructure(<End(func, _), _, _>) {
    if((Function)`<Identifier name> <SimpleStructure* args> = <Expression _>;` := func)
        return (Structure)`<Identifier name> <SimpleStructure* args>`;
    else throw "unreachable";
} 

list[Structure] getStructures([first, *rest]) = getStructure(first) + getStructures(rest);
list[Structure] getStructures([]) = [];


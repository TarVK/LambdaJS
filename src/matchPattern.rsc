module matchPattern
import Lang;
import util::Maybe;
import List;
import util::Math;
import abstractData;


// Create a matchList from the Structure CST, to simplify matching
data MatchList = Match(
	int depth,
	Const match,
	MatchList rest
) | Variable(
 	int depth,
 	str name,
 	MatchList rest
) | End();

str asStr(Match(depth, Const(name, _, _), rest)) {
	str restStr = asStr(rest);
	return "[<depth>: <name>] -\> <restStr>";
}
str asStr(Variable(depth, name, rest)) {
	str restStr = asStr(rest);
	return "[<depth>: <name>] -\> <restStr>";
}
str asStr(End()) = "null";
	
public MatchList createMatchList(
	list[Const] constructors, 
	int depth, 
	MatchList next, 
	(Structure)`<Identifier const> <SimpleStructure* params>`) {
	if (just(constructor) := findConstructor(constructors, asStr(const)))
		return Match(depth, constructor, createMatchList(constructors, depth+1, next, [ss | SimpleStructure ss <- params]));
	// TODO: proper error handling in type
	throw "Error";
}
public MatchList createMatchList(
	list[Const] constructors, 
	int depth, 
	MatchList next, 
	 [(SimpleStructure)`<Identifier first>`, *rest]) 
	= Variable(depth, asStr(first), createMatchList(constructors, depth, next, rest));	
public MatchList createMatchList(
	list[Const] constructors, 
	int depth, 
	MatchList next, 
	[(SimpleStructure)`(<Structure substructure>)`, *rest]) 
	= createMatchList(constructors, depth, createMatchList(constructors, depth, next, rest), substructure);	
public MatchList createMatchList(
	list[Const] constructors, 
	int depth, 
	MatchList next, 
	[]) = next;
	
public Maybe[Const] findConstructor([Const first, *rest], str name) {
	if (Const(name, _, _) := first) return just(first);
	else return findConstructor(rest, name);
}
public Maybe[Const] findConstructor([], str name) = nothing();

// Create an abstract match tree 
alias Substitution = map[str, list[int]];
alias OnHold = bool;
alias SubstitutedMatchList = tuple[MatchList, Substitution, Expression, OnHold];
data MatchTree = Param(
	list[int] paramPath,
	MatchTree rest
) | Split(
	list[int] splitPath,
	map[Const, MatchTree] matchers,
	MatchTree rest
) | ST(
	Expression expression,
	Substitution substitution
) | Undefined();


public int getDepth(<Match(depth, _, _), _, _, _>) = depth;
public int getDepth(<Variable(depth, _, _), _, _, _>) = depth;
public int getDepth(<End(), _, _, _>) = -1; 

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

public Maybe[SubstitutedMatchList] constNext(<MatchList ml, Substitution sub, Expression exp, true>, list[int] param, Const const) 
	= just(<ml, sub, exp, true>); 
public Maybe[SubstitutedMatchList] constNext(<Match(_, c, next), Substitution sub, Expression exp, false>, list[int] param, Const const) {
	if(const == c) return just(<next, sub, exp, false>);
	else return nothing();
}   
public Maybe[SubstitutedMatchList] constNext(<Variable(_, name, next), Substitution sub, Expression exp, false>, list[int] param, Const const) 
	= just(<next, sub + (name: param), exp, true>);
public Maybe[SubstitutedMatchList] constNext(<End(), Substitution sub, Expression exp, false>, list[int] param, Const const) 
	= nothing();
	
	
public Maybe[SubstitutedMatchList] restNext(<MatchList ml, Substitution sub, Expression exp, true>, list[int] param) 
	= just(<ml, sub, exp, true>); 
public Maybe[SubstitutedMatchList] restNext(<Match(_, _, _), Substitution sub, Expression exp, false>, list[int] param) 
	= nothing();
public Maybe[SubstitutedMatchList] restNext(<Variable(_, name, next), Substitution sub, Expression exp, false>, list[int] param) 
	= just(<next, sub + (name: param), exp, false>);
public Maybe[SubstitutedMatchList] restNext(<End(), Substitution sub, Expression exp, false>, list[int] param) 
	= nothing();

public MatchTree createMatchTree(list[Const] constructors, list[SubstitutedMatchList] matches, list[int] pos, list[Const] constPath) {
	int depth = size(pos)-1;
		
	// Check for too many params for constructors
	if ([*constPathStart, Const(_, paramCount, _)] := constPath && [*posStart, int prevIndex, int index] := pos && index >= paramCount) {
		list[SubstitutedMatchList] tooManyParams = [m | m <- matches, getDepth(m) == depth];
		
		if (size(tooManyParams) > 0) throw "error"; // TODO: improve
		int newDepth = depth-1;
		list[SubstitutedMatchList] newMatches = [<m, sub, exp, onHold && getDepth(ml) < newDepth> | ml <- matches, <m, sub, exp, onHold> := ml];
		
		return createMatchTree(constructors, newMatches, posStart + (prevIndex+1), constPathStart);
	}
	
	// Check for too few arguments for constructors
	if (depth > 0) {
		list[SubstitutedMatchList] tooFewParams = [m | m <- matches, <_, _, _, false> := m && getDepth(m) < depth];
		if (size(tooFewParams) > 0) throw "error"; // TODO: improve
	}
	
	// Check for too many params for function
	if (depth == 0) {
		list[SubstitutedMatchList] finished = [m | m <- matches, getDepth(m) == -1];
		if (size(finished) > 0) {
			list[SubstitutedMatchList] notFinished = [m | m <- matches, getDepth(m) > -1];
			if(size(notFinished) > 0) throw "error"; // TODO: improve
			
			if(<_, Substitution sub, Expression exp, _> := head(finished)) 
				return ST(exp, sub);
			else throw "Unreachable";
		}		
		if (size(matches) == 0) return Undefined();
	}
	
	// Split the tree	
	list[Const] applicableConstructors = 
		[constructor | constructor <- constructors, size([c | <Match(d, c, _),_,_,_> <- matches, c == constructor && d == depth])>0];
	map[Const, MatchTree] patternMatchesMap = (
		constructor: {
			list[SubstitutedMatchList] constMatches = [k | m <- matches, just(k) := constNext(m, pos, constructor)];
			createMatchTree(
				constructors,
				constMatches,
				pos + 0,
				constPath + constructor		
			);
		} | constructor <- applicableConstructors);


	list[int] nextPos = [];
	if ([*begin, int last] := pos) nextPos = begin + (last + 1);
	list[SubstitutedMatchList] restMatches = [k | m <- matches, just(k) := restNext(m, pos)];
	MatchTree restTree = createMatchTree(
		constructors,
		restMatches,
		nextPos,
		constPath		
	);
	
	MatchTree fullTree = restTree;  
	if (size(applicableConstructors)>0) fullTree = Split(pos, patternMatchesMap, restTree);
	
	if (depth==0) return Param(pos, fullTree);
	return fullTree;
}


module abstractData
import Lang;
import util::Maybe;

public data Const = Const(
    str name,
    int paramCount,
    Maybe[Constructor] const
);

public data Declarations = Declarations(
    map[str, Const] constructors,
    map[str, list[Function]] functions
);


public alias Errors = set[Error];
public data Error = TooFewArguments(
    Const constructor,
    Structure structure
) | TooManyArguments(
    Const constructor,
    Structure structure
) | TooFewParameters(
    list[Structure] longerAlts,
    Structure structure
) | DuplicateDecaration(
    Const constructor,
    Constructor duplicate
) | UnknownFunction (
    Identifier
);

public alias WithErrors[&U] = tuple[&U, Errors];



public alias Substitution = map[str, list[int]];
public alias OnHold = bool;
public data MatchTree = Param(
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
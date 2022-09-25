module abstractData
import Lang;

public data Const = Const(
    str name,
    int paramCount,
    Constructor const
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
);

public alias WithErrors[&U] = tuple[&U, Errors];
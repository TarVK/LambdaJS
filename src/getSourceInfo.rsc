module getSourceInfo
import Lang;

public str getName((Constructor)`<ConstructorName name> <Identifier* parts>;`) = "<name>";
public str getName((Function)`<Structure struct>=<Expression exp>;`) = getName(struct);
public str getName((Structure)`<Identifier name> <SimpleStructure* structure>`) = "<name>";

public list[Identifier] getParams((Constructor)`<ConstructorName name> <Identifier* parts>;`) = [id | id <- parts];
public list[Identifier] getParams((Function)`<Identifier name> <SimpleStructure+ strucutures>=<Expression exp>;`) = [*getParams(st) | st <- strucutures];
public list[Identifier] getParams((Function)`<Identifier name>=<Expression exp>;`) = [];
public list[Identifier] getParams((SimpleStructure)`<Identifier name>`) = [name];
public list[Identifier] getParams((SimpleStructure)`(<Structure st>)`) = getParams(st);
public list[Identifier] getParams((Structure)`<Identifier name><SimpleStructure* structures>`) = [*getParams(st) | st <- structures];

public list[Identifier] getReferences((Expression)`<SimpleExpression+ expressions>`) = [*getReferences(exp) | exp <- expressions];
public list[Identifier] getReferences((SimpleExpression)`<Identifier id>`) = [id];
public list[Identifier] getReferences((SimpleExpression)`(<Expression exp>)`) = getReferences(exp);
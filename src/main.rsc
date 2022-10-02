module main
import Lang;
import abstractData;
import IO;
import String;
import Set;
import ParseTree;
import matchPattern;
import collectDeclarations;
import orderDeclarations;
import asStr;
import compileFunction;
import compileConstructor;
import lambdaHelpers;
import jsDataConverters;
import util::Maybe;

public Program parse(str txt) {
    try 
        return parse(#Program, txt, allowAmbiguity=true);
    catch Ambiguity(loc l, str s, _):
        println("the input is ambiguous for <s> on line <l.begin.line>");
    throw "";
}
public void testProgram() {
    Program program = parse(readFile(|file:///I:/projects/Github/LambdaJS/src/testSyntax.txt|));
    
    //program = replaceKeywords(program); // Why doesn't this work??
    
    Errors allErrors = {};
    if (<Declarations(constructors, functionDeclarations, optOutput), declarationErrors> := collectDeclarations(program)) {
        allErrors += declarationErrors;
    
        str output = "Undefined(_)";
        if (just(out) := optOutput)
            if ((Output)`output <Expression exp> ;` := out)
                output = lazyLambdaExpression(exp, ());
                                
        list[Const] constructorList = getConstructorList(constructors);
        if (<order, unknownErrors> := orderDeclarations(functionDeclarations, constructors)) {
            allErrors += unknownErrors;
            list[DefinitionGroup] declarations = []; 

            for (Const constructor <- constructorList)
                if (Const(name, _, _) := constructor)
                    declarations += DG(false, (name: compileConstructor(constructor, constructorList)));
            
            set[int] definerSizes = {0};
            for (fg <- order) {
                if (FG(recurses, funcNames) := fg) {
                    map[str, str] definitions = ();
                    for(str funcName <- funcNames) {
                        list[Function] functions = functionDeclarations[funcName];
                        
                        list[MatchListOrError] matchLists = [createMatchList(constructorList, function) | function <- functions]; 
                        list[SubstitutedMatchList] matches = [<ml, (), false> | mlOrError <- matchLists, ML(ml) := mlOrError];
                        if(<split, patternErrors> := createMatchTree(constructorList, matches)){
                            allErrors += patternErrors;                        
                            definitions += (funcName: compileFunction(split, constructorList));
                        }
                        
                        for(E(error) <- matchLists) allErrors += error;
                    }
                    declarations += DG(recurses, definitions);
                    if(recurses) definerSizes += size(funcNames);
                }
            }
                
            str body = combineDefinitions(declarations, output);
            str out = wrapHelpers(body, definerSizes);
            
            println();
            println(asStr(allErrors));
            println();
            println("v = "+out);
            println();
            println(createJSEncoders(constructorList));
            println();
            println(createJSDecoders(constructorList));
            println();
            println("console.log(decode(_=\>v(_)(encode(\"(S (S Z))\"))))");
        }
    }
    
}

public list[Const] getConstructorList(map[str, Const] constructors) 
    = [constructors[s] | s <- constructors];
    
public str asStr({Error error, *rest}) = "<asStr(error)>, <asStr(rest)>";
public str asStr({}) = "";
public str asStr(TooFewArguments(Const(constr, _, _), struct)) = "TooFewArguments(<constr>, <struct>)";
public str asStr(TooManyArguments(Const(constr, _, _), struct)) = "TooManyArguments(<constr>, <struct>)";
public str asStr(TooFewParameters(longerAlts, struct)) = "TooFewParameters([<asStr(longerAlts)>], <struct>)";
public str asStr(DuplicateDecaration(Const(constr, _, _), dupl)) = "DuplicateDeclaration(<constr>, <dupl>)";
public str asStr(UnknownIdentifier(id)) = "UnknownIdentifier(<id>)";
public str asStr(MissingOutput()) = "MissingOutput()";
public str asStr(DuplicateOutput(output, duplicate)) = "DuplicateOutput(<output>, <duplicate>)";
public str asStr(UnknownConstructor(id)) = "UnknownConstructor(<id>)";
public str asStr([Structure st, *rest]) = "<st>, <asStr(rest)>";
public str asStr([]) = "";



set[str] jsKeywords = {"if"};
public Identifier removeKeyword(Identifier id) {
    if ("<id>" in jsKeywords) return parse(#Identifier, "$<id>"); // There's a better way to do this, right?
    return id;
} 

public Program replaceKeywords(Program program) =
    innermost visit (program) {
        case (Function)`<Identifier id> <SimpleStructure* ss> "=" <Expression exp>;`: {
            Identifier newId = removeKeyword(id);
            return (Function)`<Identifier newId> <SimpleStructure* SS> "=" <Expression exp>;`;
        }
        case (SimpleStructure)`<Identifier id>`: {
            Identifier newId = removeKeyword(id);
            return (SimpleStructure)`<Identifier newId>`;
        }
        case (Structure)`<Identifier id> <SimpleStructure* ss>`: {
            Identifier newId = removeKeyword(id);
            return (Structure)`<Identifier newId> <SimpleStructure* ss>`;
        }
        case (SimpleExpression)`<Identifier id>`: {
            Identifier newId = removeKeyword(id);
            return (SimpleExpression)`<Identifier newId>`;
        }
    };

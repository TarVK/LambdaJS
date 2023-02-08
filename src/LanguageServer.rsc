module LanguageServer

import Lang;
import abstractData;
import collectDeclarations;
import matchPattern;
import orderDeclarations;
import compileFunction;
import compileConstructor;
import lambdaHelpers;
import jsEscape;

import util::LanguageServer;
import util::IDEServices;
import ParseTree;
import util::Reflective;
import util::Maybe;
import IO;
import Set;
import getSourceInfo;

// a minimal implementation of a DSL in rascal
// users can add support for more advanced features
set[LanguageService] lambdaJSContributions() = {
    parser(parser(#start[Program])),
    outliner(lambdaJSOutliner),
    summarizer(lambdaJSSummarizer, providesImplementations = false),
    completer(lambdaJSCompleter),
    executor(lambdaJSExecutor),
    lenses(lambdaJSLenseDetector)
};

// We allow users to evaluate the code from the output statement
value lambdaJSExecutor(Command command) {
    if(execute(input) := command && just(<code, constructors>) := compileLambdaJS(input)) {
        loc path = |https://tarvk.github.io/LambdaJS/interaction?constructors=<urlEncode(constructors)>&func=<urlEncode(code)>|;
        browse(path);
        return ("result": true);
    }
    return 0;
}

public Maybe[tuple[str, str]] compileLambdaJS(start[Program] input) {
    start[Program] escapedInput = jsEscape(input);

    // In this compilation, the errors are ignored
    if(<Declarations(constructors, functionDeclarations, optOutput), declarationErrors> := collectDeclarations(escapedInput) 
        && <Declarations(orConstructors, _, _), _> := collectDeclarations(input) 
        && <order, unknownErrors> := orderDeclarations(functionDeclarations, constructors)) {
        list[Const] constructorList = [constructors[s] | s <- constructors];

        map[str, list[MatchListOrError]] functionMatches = (funcName: matchLists | 
            funcName <- functionDeclarations, 
            matchLists := [createMatchList(constructorList, func) | func <- functionDeclarations[funcName]]);

        map[str, str] functionDefinitions = (funcName: compileFunction(split, constructorList) | 
            funcName <- functionMatches, 
            matchLists := [<ml, (), false> | ML(ml) <- functionMatches[funcName]], 
            <split, patternErrors> := createMatchTree(constructorList, matchLists));

        list[DefinitionGroup] constructorDefinitions = [DG(false, (name:  compileConstructor(constructor, constructorList))) | 
            constructor <- constructorList,
            Const(name, _, _) := constructor];
        list[DefinitionGroup] orderedFunctionDefinitions = [DG(recurses, funcDefinitions) | 
            FG(recurses, funcNames) <- order, 
            funcDefinitions := (name: functionDefinitions[name] | name <- funcNames)];

        set[int] definerSizes = {0} + {size(funcNames) | FG(recurses, funcNames) <- order};

        str output = just(out) := optOutput && (Output)`output <Expression exp> ;` := out 
            ? lazyLambdaExpression(exp, ())
            : "Undefined(_)";
        str body = combineDefinitions(constructorDefinitions + orderedFunctionDefinitions, output);
        str out = wrapHelpers(body, definerSizes);

        map[str, str] orConstructorNames = ("<jsEscape("<orConstrName>")>": "<orConstrName>" | orConstrName <- orConstructors);
        str constrString = toString([[orConstructorNames[name], paramCount] | Const(name, paramCount, _) <- constructorList]);

        return just(<out, constrString>);
    }

    return nothing();
}

data Command = execute(start[Program] program);

rel[loc, Command] lambdaJSLenseDetector(start[Program] input) {
    if(<Declarations(constructors, functionDeclarations, optOutput), declarationErrors> := collectDeclarations(input) && just(output) := optOutput) {
        return {<output.src, execute(input, title="Evaluate")>};
    }
    return {};
}

// We build a simple outline based on the grammar
list[DocumentSymbol] lambdaJSOutliner(start[Program] input) {
    if(<Declarations(constructors, functionDeclarations, optOutput), declarationErrors> := collectDeclarations(input)) {
        return [
            *[symbol("<getName(constr)>", \constructor(), constr.src, children=children) | /Constructor constr := input, children := [
                symbol("<id>", \variable(), id.src) | id <- getParams(constr)
            ]], 
            *[symbol(name, \function(), head(functionDeclarations[name]).src) | name <- functionDeclarations]
        ];
    }
    return [];
}

// We build a summary based on grammar + assembler
Summary lambdaJSSummarizer(loc l, start[Program] input) {    
    if(<Declarations(constructors, functionDeclarations, optOutput), declarationErrors> := collectDeclarations(input)) {
        list[Const] constructorList = [constructors[s] | s <- constructors];

        map[str, tuple[loc, str]] globalDefs = 
            (getName(func): <func.src, "*Function* <getName(func)>"> | /Function func := input)
            + (getName(constr): <constr.src, "*Constructor* <getName(constr)>"> | /Constructor constr := input);
        map[str, list[MatchListOrError]] functionMatches = (funcName: matchLists | funcName <- functionDeclarations, matchLists := [createMatchList(constructorList, func) | func <- functionDeclarations[funcName]]);
        rel[loc, loc, str] defsOfUses = {*getUsesInFunction(globalDefs, func) | funcName <- functionMatches, func <- functionMatches[funcName]} 
            + {*getUsesInFunction(globalDefs, exp) | /(Output)`output <Expression exp> ;` := input};

        Errors matchListErrors = {e | funcName <- functionMatches, E(e) <- functionMatches[funcName]};
        Errors matchErrors = {*patternErrors | 
            funcName <- functionMatches, 
            matchLists := [<ml, (), false> | ML(ml) <- functionMatches[funcName]], 
            <split, patternErrors> := createMatchTree(constructorList, matchLists)};
        Errors unknownErrors = orderDeclarations(functionDeclarations, constructors)<1>
            + {*getUnknownInExpression(exp, functionDeclarations, constructors ) | /(Output)`output <Expression exp> ;` := input};

        Errors allErrors = matchListErrors + matchErrors + declarationErrors + unknownErrors;

        return summary(l,
            messages = getErrors(l, allErrors),
            references = defsOfUses<1, 0>,
            definitions = defsOfUses<0, 1>,
            documentation = defsOfUses<0, 2>
        );
    }
    return summary(l, messages = {}, references = {}, definitions = {}, documentation = {} );
}

list[Completion] lambdaJSCompleter(Tree input, str prefix, int offset) {
    return [completion("text")];
}

rel[loc, loc, str] getUsesInFunction(map[str, tuple[loc, str]] defs, E(error)) = {};
rel[loc, loc, str] getUsesInFunction(map[str, tuple[loc, str]] defs, ML(ml)) = getUsesInFunction(defs, ml);
rel[loc, loc, str] getUsesInFunction(map[str, tuple[loc, str]] defs, Match(_, _, rest, structure)) = getUsesInFunction(defs, rest) + getUsesInFunction(defs, structure);
rel[loc, loc, str] getUsesInFunction(map[str, tuple[loc, str]] defs, Variable(_, name, rest, id)) = getUsesInFunction(defs + (name: <id.src, "*Parameter* <id>">), rest);
rel[loc, loc, str] getUsesInFunction(map[str, tuple[loc, str]] defs, End(_, exp)) = getUsesInFunction(defs, exp);
rel[loc, loc, str] getUsesInFunction(map[str, tuple[loc, str]] defs, (Structure)`<Identifier id><SimpleStructure* ss>`) = {<id.src, loca, doc> | <loca, doc> := defs["<id>"]};
rel[loc, loc, str] getUsesInFunction(map[str, tuple[loc, str]] defs, (Structure)`<Identifier id><SimpleStructure* ss>`) = {<id.src, loca, doc> | <loca, doc> := defs["<id>"]};
rel[loc, loc, str] getUsesInFunction(map[str, tuple[loc, str]] defs, Expression exp) = {<use.src, loca, doc> | use <- getReferences(exp), "<use>" in defs, <loca, doc> := defs["<use>"]};

rel[loc, Message] getErrors(loc l, {first, *rest}) = getErrors(l, first) + getErrors(l, rest);
rel[loc, Message] getErrors(loc l, TooFewArguments(_, structure)) = 
    {<structure.src, error("Not enough constructor arguments were provided", structure.src)>};
rel[loc, Message] getErrors(loc l, TooManyArguments(_, structure)) = 
    {<structure.src, error("Too many constructor arguments were provided", structure.src)>};
rel[loc, Message] getErrors(loc l, TooFewParameters(_, structure)) = 
    {<structure.src, error("Not enough parameters were specified. There exist alternative definitions with more parameters, which prevent case matching", structure.src)>};
rel[loc, Message] getErrors(loc l, DuplicateDecaration(_, constr)) = 
    {<constr.src, error("Constructor was already declared", constr.src)>};
rel[loc, Message] getErrors(loc l, UnknownIdentifier(id)) = 
    {<id.src, error("Identifier has not been declared", id.src)>};
rel[loc, Message] getErrors(loc l, UnknownConstructor(id)) = 
    {<id.src, error("Constructor has not been declared", id.src)>};
rel[loc, Message] getErrors(loc l, MissingOutput()) = 
    {<l, error("No output has been specified", l)>};
rel[loc, Message] getErrors(loc l, DuplicateOutput(_, d)) = 
    {<d.src, error("Only a single output may be specified", d.src)>};
rel[loc, Message] getErrors(loc l, value val) = {};

// run this from a REPL while developing the DSL
int main() {
    // we register a new language to Rascal's LSP multiplexer
    // the multiplexer starts a new evaluator and loads this module and function
    registerLanguage(
        language(
            pathConfig(srcs=[|project://LambdaJS/src|]),
            "LambdaJS", // name of the language
            "ljs", // extension
            "LanguageServer", // module to import
            "lambdaJSContributions"
        )
    );
    return 0;
}

void testCompile() {
    start[Program] program = parse(#start[Program], readFile(|file:///I:/projects/Github/LambdaJS/examples/odd.ljs|));
    print(jsEscape(program));
    // compileLambdaJS(program);
}
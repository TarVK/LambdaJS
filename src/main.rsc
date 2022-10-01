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

public Program parse(str txt) = parse(#Program, txt);
public void testProgram() {
    Program program = parse(readFile(|file:///I:/projects/Github/LambdaJS/src/testSyntax.txt|));
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
            for (fg <- order)
                if (FG(recurses, funcNames) := fg) {
                    map[str, str] definitions = ();
                    for(str funcName <- funcNames) {
                        list[Function] functions = functionDeclarations[funcName];
                        list[SubstitutedMatchList] matches = [<createMatchList(constructorList, function), (), false> | function <- functions];
                        if(<split, patternErrors> := createMatchTree(constructorList, matches)){
                            allErrors += patternErrors;                        
                            definitions += (funcName: compileFunction(split, constructorList));
                        }
                    }
                    declarations += DG(recurses, definitions);
                    if(recurses) definerSizes += size(funcNames);
                }
                
            str body = combineDefinitions(declarations, output);
            str out = wrapHelpers(body, definerSizes);
            
            println(allErrors);
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


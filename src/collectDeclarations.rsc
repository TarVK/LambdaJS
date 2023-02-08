module collectDeclarations
import getSourceInfo;
import abstractData;
import Lang;
import asStr;
import List;
import util::Maybe;
import IO;

public WithErrors[Declarations] collectDeclarations(start[Program] program) {
    map[str, Const] constructors = ("Undefined": Const("Undefined", 0, nothing()));
    map[str, list[Function]] functions = ();
    Maybe[Output] output = nothing(); 
    Errors errors = {};
    
    visit (program) {
        case (Declaration)`<Constructor const>`: {
            if ((Constructor)`<ConstructorName nameC><Identifier* parts>;` := const){
                list[Identifier] partsList = [p | Identifier p <- parts];
                str name = "<nameC>";
                
                if (name in constructors) errors += DuplicateDecaration(constructors[name], const);   
                else constructors += (name: Const(name, size(partsList), just(const)));
            }
        }
        case (Declaration)`<Function function>`: {
            str name = "<getName(function)>";            
            if (!(name in functions)) functions[name] = [];
            functions[name] += function;
        }
        case (Statement)`<Output out>`: {
            if(just(curOut) := output) {
                errors += DuplicateOutput(curOut, out);
            } else
                output = just(out);
        }
    }
    
    if(nothing() := output)
        errors += MissingOutput();
    
    return <Declarations(constructors, functions, output), errors>;
}
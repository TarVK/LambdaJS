module collectDeclarations
import abstractData;
import Lang;
import asStr;
import List;
import util::Maybe;

public WithErrors[Declarations] collectDeclarations(Program program) {
    map[str, Const] constructors = ("Undefined": Const("Undefined", 0, nothing()));
    map[str, list[Function]] functions = ();
    Maybe[Output] output = nothing(); 
    Errors errors = {};
    
    visit (program) {
        case (Declaration)`<Constructor const>`: {
            if ((Constructor)`<Identifier+ parts>;` := const){
                list[Identifier] partsList = [p | Identifier p <- parts];
                str name = "<head(partsList)>";
                
                if (name in constructors) errors += DuplicateDecaration(constructors[name], const);   
                else constructors += (name: Const(name, size(partsList)-1, just(const)));
            }
        }
        case (Declaration)`<Function function>`: {
            if ((Function)`<Identifier id> <SimpleStructure* _> = <Expression _>;` := function) {
                str name = "<id>";
                if (!(name in functions)) functions[name] = [];
                functions[name] += function;
            }
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
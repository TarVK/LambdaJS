module collectDeclarations
import abstractData;
import Lang;
import asStr;
import List;

public WithErrors[Declarations] collectDeclarations(Program program) {
    map[str, Const] constructors = ();
    map[str, list[Function]] functions = ();
    Errors errors = {};
    
    visit (program) {
        case (Declaration)`<Constructor const>`: {
            if ((Constructor)`<Identifier+ parts>;` := const){
                list[Identifier] partsList = [p | Identifier p <- parts];
                str name = asStr(head(partsList));
                
                if (name in constructors) errors += DuplicateDecaration(constructors[name], const);   
                else constructors += (name: Const(name, size(partsList)-1, const));
            }
        }
        case (Declaration)`<Function function>`: {
            if ((Function)`<Identifier id> <SimpleStructure* _> = <Expression _>;` := function) {
                str name = asStr(id);
                if (!(name in functions)) functions[name] = [];
                functions[name] += function;
            }
        }
    }
    
    return <Declarations(constructors, functions), errors>;
}
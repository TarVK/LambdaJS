module compileConstructor
import abstractData;
import List;

public str compileConstructor(Const constructor, list[Const] constructors) {
    int constCount = size(constructors);
    if(Const(_, paramCount, _) := constructor)
        return ("" | it + toParam(v) + "=\>" | v <- [0..constCount+paramCount]) 
                + toParam(paramCount + indexOf(constructors, constructor))
                + "(_)"
                + ("" | it + "(<toParam(v)>)" | v <- [0..paramCount]);
    return "";
} 
    
str toParam(int pos) = "$<pos>";
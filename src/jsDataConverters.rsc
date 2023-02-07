module jsDataConverters
import abstractData;
import lambdaHelpers;
import List;
import IO;

public str createJSEncoders(list[Const] constructors) {
    str lookup = "{";
    int i = 0;
    for (Const(name, paramCount, _) <- constructors) {
        lookup += "\"<name>\":[<paramCount>,_=\><
            defineParams("a", paramCount)><defineParams(size(constructors))>$<i>(_)<applyArgs("a", paramCount)>],";
        i += 1;
    }
    lookup += "}";
    return "const encode=r=\>{let t=[...r.split(/\\s*(?:\\b|(?=[)(]))\\s*/),null],n=0,e=r=\>t[n]==r,o=()=\>t[n++],l=<lookup>,u=()=\>{let r=!1;e(\"(\")&&(o(),r=!0);let t=o();if(!(t in l))throw Error(`Unknown constructor \"${t}\"`);let[n,s]=l[t],i=s(id);for(let c=0;c\<n;c++){if(e(\")\")||e(null))throw Error(`Constructor \"${t}\" requires ${n} arguments`);i=i(u())}if(r){if(!(e(\")\")||e(null)))throw Error(`Constructor \"${t}\" requires ${n} arguments`);e(\")\")&&o()}return r=\>i};return u()};";
}


public str createJSDecoders(list[Const] constructors) {
    str decoder = "decode = val=\>val(_=\>_)";
    for (Const(name, paramCount, _) <- constructors) {
        decoder += "(_=\>";
        decoder += defineParams(paramCount);
        decoder += "\"(<name>\"";
        for (i <- [0..paramCount]) 
            decoder += "+\" \"+decode($<i>)";
        decoder += "+\")\")";
    }
    
    return decoder;
}

// A reference to the code that was minified
str encodeReference = "encode = val=\>{
    const tokens = [...val.split(/\\s*(?:\\b|(?=[)(]))\\s*/), null];
    let i = 0;
    const peek = val=\>tokens[i]==val;
    const consume = ()=\>tokens[i++];

    const lookup = TODO;

    const data = ()=\>{
        let opened = false;
        if(peek(\"(\")) {
            consume();
            opened = true;
        }
        
        const name = consume();
        if(!(name in lookup)) throw Error(`Unknown constructor \"${name}\"`);
        const [argCount, func] = lookup[name];

        let val = func(_=\>_);
        for(let i=0; i\<argCount; i++) {
            if(peek(\")\") || peek(null)) throw Error(`Constructor \"${name}\" requires ${argCount} arguments`);
            val = val(data());
        }
        if(opened) {
            if(!(peek(\")\") || peek(null))) throw Error(`Constructor \"${name}\" requires ${argCount} arguments`);
            if(peek(\")\")) consume();
        }
        return _=\>val;
    }
    
    return data();
}";
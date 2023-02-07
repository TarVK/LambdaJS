const createConverters = (constructors, funcName, func)=>{
    // Ith constructor format, with n params, and m total constructors: _=>arg1=>...=>argN=>constr1=>...=>constrM=> constrI(_)(arg1)(...)(argN)

    const decode = val=>
        applyArguments(val(id), constructors.map(([name, paramCount])=>
            // Creates E.g _=>arg1=>arg2 => `(Name ${decode(arg1)} ${decode(arg2)})`
            _=>{
                const joinedStringGetter = repeat(name, (cur, i)=>transformValue(cur, i, val=>arg=>val+" "+decode(arg)), paramCount);
                return transformValue(joinedStringGetter, paramCount, val=>`(${val})`);
            }
        ))

    const lookup = Object.fromEntries(constructors.map(([name, paramCount], i)=>
        [name, [paramCount, createConstructor(i, paramCount, constructors.length)]]));
    lookup[funcName] = [-1, func];

    const encode = val=>{
        const tokens = [...val.split(/\s*(?:\b|(?=[)(]))\s*/), null];
        let i = 0;
        const peek = val=>tokens[i]==val;
        const consume = ()=>tokens[i++];
    
        const data = ()=>{
            let opened = false;
            if(peek("(")) {
                consume();
                opened = true;
            }
            let atEnd = ()=>peek(")") || peek(null);
            
            const name = consume();
            if(!(name in lookup)) throw Error(`Unknown constructor "${name}"`);
            const [argCount, func] = lookup[name];
    
            let val = func(id);
            for(let i=0; i<argCount || (argCount==-1 && !atEnd()); i++) {
                if(atEnd()) throw Error(`Constructor "${name}" requires ${argCount} arguments`);
                val = val(data());
            }
            if(opened) {
                if(!atEnd()) throw Error(`Constructor "${name}" requires ${argCount} arguments`);
                if(peek(")")) consume();
            }
            return _=>val;
        }
        
        return data();
    }

    return {decode, encode};
}


/**
 * Below are some function transformation helpers.
 * It would've been easier to just create a function string and use eval, and more efficient too, but this was a fun challenge. 
 * Requires using the functional programming mindset a bit, and think rather abstractly. 
 */ 

/**
 * Creates a constructor function
 * E.g.
 * createConstructor(1, 2, 3) 
 * == _=>arg1=>arg2=>constr1=>constr2=>constr3 => constr2(_)(arg1)(arg2)
 */
const createConstructor = (index, paramCount, constrCount) =>{
    const suffixed = addRedundantParams(id, 1, constrCount-index-1); // > constr2=>constr3 => constr2
    const prefixed = addRedundantParams(suffixed, 0, index);         // > constr1=>constr2=>constr3 => constr2
    return moveParamsToFront(prefixed, constrCount, paramCount+1)    // > _=>arg1=>arg2=>constr1=>constr2=>constr3 => constr2(_)(arg1)(arg2)
}

/**
 * Repeats a given transformation on an input for the given number of cycles
 * E.g.
 * repeat(0, val => val + 2, 3)
 * == 6
 */
const repeat = (input, transform, count) => count == 0
    ? input
    : transform(repeat(input, transform, count-1), count-1);

/**
 * Moves a given parameter to be the new first parameter
 * E.g.
 * moveParamToFront(a=>b=>c=>d=>smth(a,b,c,d), 2) 
 * == arg=>a=>b=>(c=>d=>smth(a,b,c,d))(arg) 
 * == c=>a=>b=>d=>smth(a,b,c,d)
 */
const moveParamToFront = (func, paramIndex) => paramIndex == 0 
    ? func
    : newParam => arg => moveParamToFront(func(arg), paramIndex-1)(newParam);

/**
 * Moves a given range of parameters to be the new first parameters
 * E.g.
 * moveParamsToFront(a=>b=>c=>d=>e=>smth(a,b,c,d,e), 2, 2) 
 * == c=>d=>a=>b=>e=>smth(a,b,c,d,e)
 */
const moveParamsToFront = (func, paramIndex, paramCount) => 
    repeat(func, out => moveParamToFront(out, paramIndex+paramCount-1), paramCount);
    
/**
 * Transforms the return value of a function
 * E.g.
 * transformValue(a=>b=>c=>smth(a, b, c), 3, val=>val+1)
 * == a=>b=>c=>smth(a, b, c)+1
 */
const transformValue = (func, depth, transform) => depth == 0
    ? transform(func)
    : arg => transformValue(func(arg), depth-1, transform)

/**
 * Inserts a single unused parameter in the function signature
 * E.g.
 * addRedundantParam(a=>b=>smth(a, b), 1)
 * == a=>arg=>b=>smth(a, b)
 */
const addRedundantParam = (func, depth) => transformValue(func, depth, val=>arg=>val);

/**
 * Inserts a number of unused parameters in the function signature
 * E.g.
 * addRedundantParams(a=>b=>smth(a, b), 1, 2)
 * == a=>arg1=>arg2=>b=>smth(a,b)
 */
const addRedundantParams = (func, depth, count) => 
    repeat(func, out => addRedundantParam(out, depth), count);

/** The identity function */
const id = x=>x;

/**
 * Applies the given list of arguments to a curried function
 * E.g.
 * applyArguments(a=>b=>c=>smth(a, b, c), [1,2,3])
 * == smth(1,2,3)
 */
const applyArguments = (func, args) => args.length == 0
    ? func
    : applyArguments(func(args[0]), args.slice(1));
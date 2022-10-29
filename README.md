# LambdaJS
A minimal pattern matching based functional language "ljs" that compiles into pure lambda expressions in JS.
This language has no practical applications, and was merely designed in order to mess around with the programming language [Rascal](https://www.rascal-mpl.org/).

The testCode folder contains ljs code and some of the corresponding JS code.

## Language
ljs is a minimalistic pattern-matching based language. 

You can declare constructors by specfying a name followed by names for each parameter of the contructor, e.g.:
```ts
SomeNullaryConstructor;
SomeBinaryConstructor param1 param2;
```

By convention, we use capitallized names for constructors, while using lower case names for functions.

Functions can be declared just like constructors, but by adding an equal sign followed by an expression. An expression consists of (nested) constructors and functions applied to argument expressions. 
The declaration of a function can specify that a value created using a specific constructor is expected, while destructuring its arguments. This is known as pattern matching. Multiple different declarations can be specified for the same function. 

We can for instance create constructors `True` and `False` to represent booleans, and `S` (successor) and `Z` (zero) to represent natural numbers. `S` will take one argument, and specifies that the value is one higher than the argument. Then using these constructors, we can define the function `isEven` using two declarations and the helper function `not`:

```ts
True;
False;

S val;
Z;

not True = False;
not False = True;

isEven Z = True;
isEven (S x) = not (isEven x);
```

This code specifies that our base case 0, is even. Any number `y` that's bigger than 0 is defined as the successor of another number `x`, I.e. `y = x+1`. Hence if `y` is even, `x` must be odd, and vice-versa. Hence our second declaration for `isEven` specifies that a value `y` that's the successor of `x` is the negation of `isEven x`. And since `x` is smaller than `y`, this will simply recurse until the base case of 0 is eventually reached. 

Finally, we can use the keyword `output` followed by an expression in order to specify what the code should output when compiled.

### Quicksort
Below is an implementation of quicksort using ljs. This code already specifies the value to operate on as part of the script. But alternatively one may simple put `output quicksort` to output the function itself, which can then be applied to any value.

```ts
// Natural number constructors, peano numbers (Zero and Successor) and functions
Z;
S nat;

lessThan Z (S x) = True;
lessThan x Z = False;
lessThan (S x) (S y) = lessThan x y;

// Boolean constructors
False;
True;

// List constructors (linked list of sorts)
Cons head tail;
Nill;

concat Nill list = list;
concat (Cons head tail) list = Cons head (concat tail list);

// Pair constructor
Pair el1 el2;

// A function to append a value to either the left or right list, given a Pair of lists
append val (Pair list1 list2) True = Pair (Cons val list1) list2;
append val (Pair list1 list2) False = Pair list1 (Cons val list2);  

// Quicksort (except it's not quick at all when compiled)
partition val Nill = Pair Nill Nill;
partition val (Cons head tail) 
    = append head (partition val tail) (lessThan head val);
    
quicksort Nill = Nill;
quicksort (Cons head tail) = quicksort head (partition head tail);

quicksort val (Pair lessThan moreThan) 
    = concat 
        (quicksort lessThan) 
        (Cons val (quicksort moreThan)); 

// Perform quicksort on some sample data
v0 = Z;
v1 = S v0;
v2 = S v1;
v3 = S v2;
v4 = S v3;
list = Cons v3 (Cons v4 (Cons v1 (Cons v0 Nill)));

output quicksort list;
```

## Compiled JS code
The ljs language is designed to compile to a JS encoding of [lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus). It additionally outputs an encode and decode function javascript funciton, that allows for conversion between javascript strings containing ljs constructor expressions and their lambda calculus equivalent. 

<details>
    <summary>Example compiled code for quicksort</summary>

```js
v = _=>($Y=>($D0=>($D1=>$D0(_)(_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$0(_))(_=>False=>$D0(_)(_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$1(_))(_=>True=>$D0(_)(_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$2(_))(_=>Undefined=>$D0(_)(_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$8=>$9=>$5(_)($0)($1))(_=>Cons=>$D0(_)(_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$8=>$5(_)($0))(_=>S=>$D0(_)(_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$5(_))(_=>Nill=>$D0(_)(_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$6(_))(_=>Z=>$D0(_)(_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$8=>$9=>$9(_)($0)($1))(_=>Pair=>$D1(_)(_=>lessThan=>$0=>$0(_)(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>False(_))(_=>$1$0=>$1$1=>Undefined(_)))(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>False(_))(_=>$1$0=>$1$1=>Undefined(_)))(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>False(_))(_=>$1$0=>$1$1=>Undefined(_)))(_=>$0$0=>$0$1=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>False(_))(_=>$1$0=>$1$1=>Undefined(_)))(_=>$0$0=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>lessThan(_)(_=>$0$0(_))(_=>$1$0(_)))(_=>Undefined(_))(_=>False(_))(_=>$1$0=>$1$1=>Undefined(_)))(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>False(_))(_=>$1$0=>$1$1=>Undefined(_)))(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>True(_))(_=>Undefined(_))(_=>False(_))(_=>$1$0=>$1$1=>Undefined(_)))(_=>$0$0=>$0$1=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>False(_))(_=>$1$0=>$1$1=>Undefined(_))))(_=>lessThan=>$D0(_)(_=>$0=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>$2=>$2(_)(_=>Pair(_)(_=>$1$0(_))(_=>(Cons(_)(_=>$0(_))(_=>$1$1(_)))))(_=>Pair(_)(_=>(Cons(_)(_=>$0(_))(_=>$1$0(_))))(_=>$1$1(_)))(_=>Undefined(_))(_=>$2$0=>$2$1=>Undefined(_))(_=>$2$0=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$2$0=>$2$1=>Undefined(_))))(_=>append=>$D1(_)(_=>partition=>$0=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>append(_)(_=>$1$0(_))(_=>(partition(_)(_=>$0(_))(_=>$1$1(_))))(_=>(lessThan(_)(_=>$1$0(_))(_=>$0(_)))))(_=>$1$0=>Undefined(_))(_=>Pair(_)(_=>Nill(_))(_=>Nill(_)))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_)))(_=>partition=>$D1(_)(_=>concat=>$0=>$0(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$0$0=>$0$1=>$1=>Cons(_)(_=>$0$0(_))(_=>(concat(_)(_=>$0$1(_))(_=>$1(_)))))(_=>$0$0=>Undefined(_))(_=>$1=>$1(_))(_=>Undefined(_))(_=>$0$0=>$0$1=>Undefined(_)))(_=>concat=>$D1(_)(_=>quicksort=>$0=>$0(_)(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>concat(_)(_=>(quicksort(_)(_=>$1$0(_))))(_=>(Cons(_)(_=>$0(_))(_=>(quicksort(_)(_=>$1$1(_))))))))(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>concat(_)(_=>(quicksort(_)(_=>$1$0(_))))(_=>(Cons(_)(_=>$0(_))(_=>(quicksort(_)(_=>$1$1(_))))))))(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>concat(_)(_=>(quicksort(_)(_=>$1$0(_))))(_=>(Cons(_)(_=>$0(_))(_=>(quicksort(_)(_=>$1$1(_))))))))(_=>$0$0=>$0$1=>quicksort(_)(_=>$0$0(_))(_=>(partition(_)(_=>$0$0(_))(_=>$0$1(_)))))(_=>$0$0=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>concat(_)(_=>(quicksort(_)(_=>$1$0(_))))(_=>(Cons(_)(_=>$0(_))(_=>(quicksort(_)(_=>$1$1(_))))))))(_=>Nill(_))(_=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>concat(_)(_=>(quicksort(_)(_=>$1$0(_))))(_=>(Cons(_)(_=>$0(_))(_=>(quicksort(_)(_=>$1$1(_))))))))(_=>$0$0=>$0$1=>$1=>$1(_)(_=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>Undefined(_))(_=>$1$0=>Undefined(_))(_=>Undefined(_))(_=>Undefined(_))(_=>$1$0=>$1$1=>concat(_)(_=>(quicksort(_)(_=>$1$0(_))))(_=>(Cons(_)(_=>$0(_))(_=>(quicksort(_)(_=>$1$1(_)))))))))(_=>quicksort=>$D0(_)(_=>Z(_))(_=>v0=>$D0(_)(_=>S(_)(_=>v0(_)))(_=>v1=>$D0(_)(_=>S(_)(_=>v1(_)))(_=>v2=>$D0(_)(_=>S(_)(_=>v2(_)))(_=>v3=>$D0(_)(_=>S(_)(_=>v3(_)))(_=>v4=>$D0(_)(_=>Cons(_)(_=>v3(_))(_=>(Cons(_)(_=>v4(_))(_=>(Cons(_)(_=>v1(_))(_=>(Cons(_)(_=>v0(_))(_=>Nill(_)))))))))(_=>list=>quicksort(_)(_=>list(_))))))))))))))))))))))(_=>$0=>c=>(f=>c(_)(f))(_=>$Y(_)($0))))(_=>$0=>c=>c(_)($0)))(_=>f=>(x=>f(_)(_=>x(x)))(x=>f(_)(_=>x(x))))

encode=r=>{let t=[...r.split(/\s*(?:\b|(?=[)]))\s*/),null],n=0,e=r=>t[n]==r,l=()=>t[n++],u={"False":[0,_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$0(_)],"True":[0,_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$1(_)],"Undefined":[0,_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$2(_)],"Cons":[2,_=>$a0=>$a1=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$3(_)($a0)($a1)],"S":[1,_=>$a0=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$4(_)($a0)],"Nill":[0,_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$5(_)],"Z":[0,_=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$6(_)],"Pair":[2,_=>$a0=>$a1=>$0=>$1=>$2=>$3=>$4=>$5=>$6=>$7=>$7(_)($a0)($a1)],},o=()=>{let r=!1;e("(")&&(l(),r=!0);let t=l();if(!(t in u))throw Error(`Unknown function "${t}"`);let[n,s]=u[t],i=s(r=>r);for(let f=0;f<n;f++){if(e(")")||e(null))throw Error(`Constructor "${t}" requires ${n} arguments`);i=i(o())}if(r&&!(e(")")||e(null)))throw Error(`Constructor "${t}" requires ${n} arguments`);return e(")")&&l(),r=>i};return o()};

decode = val=>val(_=>_)(_=>"(False"+")")(_=>"(True"+")")(_=>"(Undefined"+")")(_=>$0=>$1=>"(Cons"+" "+decode($0)+" "+decode($1)+")")(_=>$0=>"(S"+" "+decode($0)+")")(_=>"(Nill"+")")(_=>"(Z"+")")(_=>$0=>$1=>"(Pair"+" "+decode($0)+" "+decode($1)+")")
```
</details>

This code specifies the output value `v` written in the ljs code and the `encode` and `decode` function for data conversion. 

The result can then be checked in javascript as follows:
```js
console.log(decode(v));
```
This results in the following being logged:
```
(Cons (Z) (Cons (S (Z)) (Cons (S (S (S (Z)))) (Cons (S (S (S (S (Z))))) (Nill)))))
```
Which represents `[0, 1, 3, 4]` using our functional list and number encoding. 


Additionally, if the ljs code specified `output quicksort` without the arguments for quicksort, we could apply any arguments in js as follows:
```js
console.log(decode(_=>v(_)(encode("(Cons (S Z) (Cons (Z) (Cons (S (S (S (S Z)))) (Cons (S (S (S Z))) Nill))))")))));
```
which will result in the same sorted list as above. 



### Compilation process
This repository contains rascal code for compiling ljs code to lambda expressions in JS. The rascal code has however not been turned into any proper compiler or IDE tools yet, everything but a proper interface is present.
Currently the function `testProgram` in `main.rsc` is the main entry point, which takes the code written in `testSyntax` and outputs the compiled code in the terminal. 

I may or may not get back to this and create a proper interface to allow people to use this language. Of course there's no practical reason to use this language, but it may still be nice to complete this project.

# LambdaJS
A minimal pattern matching based functional language "ljs" that compiles into pure [lambda expressions in JS](https://tarvk.github.io/articles/lambda-calculus).
This language has no practical applications, and was merely designed in order to mess around with the programming language [Rascal](https://www.rascal-mpl.org/).

The [`examples`](examples) folder contains ljs code, as well as a comment with their compiled counterpart in a link that can be used to evaluate it.

https://user-images.githubusercontent.com/26687938/217636006-14adf414-ca37-4970-a37e-7e50723f4e3f.mp4

## Language
ljs is a minimalistic pattern-matching based language. 

You can declare constructors by specfying a name followed by names for each parameter of the contructor, e.g.:
```
SomeNullaryConstructor;
SomeBinaryConstructor param1 param2;
```

By convention, we use capitallized names for constructors, while using lower case names for functions.
We can create identifiers (function/constructor names) using alphanumeric symbol, as well as any of these symbols: `@$_[]{}<>&|+\-*/\!%^#?,.:'"`

Functions can be declared just like constructors, but by adding an equal sign followed by an expression. An expression consists of (nested) constructors and functions applied to argument expressions. 
The declaration of a function can specify that a value created using a specific constructor is expected, while destructuring its arguments. This is known as pattern matching. Multiple different declarations can be specified for the same function. 

We can for instance create constructors `True` and `False` to represent booleans, and `S` (successor) and `Z` (zero) to represent natural numbers. `S` will take one argument, and specifies that the value is one higher than the argument. Then using these constructors, we can define the function `isEven` using two declarations and the helper function `not`:

```
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

As mentioned before, symbols can also be used in names. Hence we could also write the following instead:
```
0;
1+ nat;

False;
True;

! True = False;
! False = True;

isOdd 0 = False;
isOdd (1+ x) = !(isOdd x);

output isOdd;
```

Note that we have to add a space between `!` and `True`, or else it is read as a single identifier `!True`. We don't have to do this for `!(...)` because `(` can't be part of an identifier. 
The compiled code for this example can be executed here: [https://tarvk.github.io/LambdaJS/interaction/...](https://tarvk.github.io/LambdaJS/interaction/?constructors=[[%22False%22,0],[%221+%22,1],[%22True%22,0],[%22Undefined%22,0],[%220%22,0]]&func=_=%3E($Y=%3E($D0=%3E($D1=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$0(_))(_=%3EFalse=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$2(_)($0))(_=%3E_1_PLUS=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$2(_))(_=%3ETrue=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$3(_))(_=%3EUndefined=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$4(_))(_=%3E_0=%3E$D1(_)(_=%3E_EXC=%3E$0=%3E$0(_)(_=%3ETrue(_))(_=%3E$0$0=%3EUndefined(_))(_=%3EFalse(_))(_=%3EUndefined(_))(_=%3EUndefined(_)))(_=%3E_EXC=%3E$D1(_)(_=%3EisOdd=%3E$0=%3E$0(_)(_=%3EUndefined(_))(_=%3E$0$0=%3E_EXC(_)(_=%3E(isOdd(_)(_=%3E$0$0(_)))))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EFalse(_)))(_=%3EisOdd=%3EisOdd(_)))))))))(_=%3E$0=%3Ec=%3E(f=%3Ec(_)(f))(_=%3E$Y(_)($0))))(_=%3E$0=%3Ec=%3Ec(_)($0)))(_=%3Ef=%3E(x=%3Ef(_)(_=%3Ex(x)))(x=%3Ef(_)(_=%3Ex(x))))).

## VSCode integration
Using Rascal, a language server for this toy language was developed. This means the language has proper VSCode support, with the following features:
- Syntax highlighting (for syntactically correct code)
- An outline of the written code
- Navigating to parameter/function/constructor definitions (ctrl-click)
- Navigating to parameter/function/constructor usages (context-menu)
- Hover docs for parameter/function/constructor mentioning their "type"
- Error reporting for simple errors:
    - Unknown identifiers
    - Missing/too many outputs
    - Duplicate constructor declarations
    - Too few/many constructor arguments
    - Too few function parameters (only in special cases, where it breaks compilation)
- An evaluation [code lens](https://code.visualstudio.com/blogs/2017/02/12/code-lens-roundup), which opens a terminal to interact with the compiled code

https://user-images.githubusercontent.com/26687938/217636006-14adf414-ca37-4970-a37e-7e50723f4e3f.mp4

In order to use the VSCode integration, several steps are required:
- Clone the repo, and open it as the root directory in VSCode
- Install the [Rascal extension](https://marketplace.visualstudio.com/items?itemName=usethesource.rascalmpl)
- Open a rascal terminal (`ctrl-shift-p` > `create rascal terminal`)
- Enter: 
    ```
    import LanguageServer;
    main();
    ```
- Open any `.ljs` file in this VSCode session, and get ljs support.

The evaluator makes use of my old project [chromeConsole](https://github.com/TarVK/chromeConsole) in order to display a custom terminal. 

## Examples
The [examples](examples) directory contains several examples with their compiled equivalent:
- [odd](examples/odd.ljs)
- [oddEven](examples/oddEven.ljs)
- [quicksort](examples/quicksort.ljs)
- [quicksort2](examples/quicksort2.ljs)
- [infiniteData](examples/infiniteData.ljs)
- [binary](examples/binary.ljs)

### Example code: Quicksort
Below is an implementation of quicksort using ljs. This code already specifies the value to operate on as part of the script. But alternatively one may simple put `output quicksort` to output the function itself, which can then be applied to any value. This code can be evaluated [here](https://tarvk.github.io/LambdaJS/interaction/?constructors=[[%22False%22,0],[%22True%22,0],[%22Undefined%22,0],[%22Cons%22,2],[%22S%22,1],[%22Nill%22,0],[%22Z%22,0],[%22Pair%22,2]]&func=_=%3E($Y=%3E($D0=%3E($D1=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$6=%3E$7=%3E$0(_))(_=%3EFalse=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$6=%3E$7=%3E$1(_))(_=%3ETrue=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$6=%3E$7=%3E$2(_))(_=%3EUndefined=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$6=%3E$7=%3E$8=%3E$9=%3E$5(_)($0)($1))(_=%3ECons=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$6=%3E$7=%3E$8=%3E$5(_)($0))(_=%3ES=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$6=%3E$7=%3E$5(_))(_=%3ENill=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$6=%3E$7=%3E$6(_))(_=%3EZ=%3E$D0(_)(_=%3E$0=%3E$1=%3E$2=%3E$3=%3E$4=%3E$5=%3E$6=%3E$7=%3E$8=%3E$9=%3E$9(_)($0)($1))(_=%3EPair=%3E$D1(_)(_=%3ElessThan=%3E$0=%3E$0(_)(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EFalse(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_)))(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EFalse(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_)))(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EFalse(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_)))(_=%3E$0$0=%3E$0$1=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EFalse(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_)))(_=%3E$0$0=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3ElessThan(_)(_=%3E$0$0(_))(_=%3E$1$0(_)))(_=%3EUndefined(_))(_=%3EFalse(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_)))(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EFalse(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_)))(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3ETrue(_))(_=%3EUndefined(_))(_=%3EFalse(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_)))(_=%3E$0$0=%3E$0$1=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EFalse(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))))(_=%3ElessThan=%3E$D1(_)(_=%3Eappend=%3E$0=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3E$2=%3E$2(_)(_=%3EPair(_)(_=%3E$1$0(_))(_=%3E(Cons(_)(_=%3E$0(_))(_=%3E$1$1(_)))))(_=%3EPair(_)(_=%3E(Cons(_)(_=%3E$0(_))(_=%3E$1$0(_))))(_=%3E$1$1(_)))(_=%3EUndefined(_))(_=%3E$2$0=%3E$2$1=%3EUndefined(_))(_=%3E$2$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$2$0=%3E$2$1=%3EUndefined(_))))(_=%3Eappend=%3E$D1(_)(_=%3Epartition=%3E$0=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3Eappend(_)(_=%3E$1$0(_))(_=%3E(partition(_)(_=%3E$0(_))(_=%3E$1$1(_))))(_=%3E(lessThan(_)(_=%3E$1$0(_))(_=%3E$0(_)))))(_=%3E$1$0=%3EUndefined(_))(_=%3EPair(_)(_=%3ENill(_))(_=%3ENill(_)))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_)))(_=%3Epartition=%3E$D1(_)(_=%3Econcat=%3E$0=%3E$0(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$0$0=%3E$0$1=%3E$1=%3ECons(_)(_=%3E$0$0(_))(_=%3E(concat(_)(_=%3E$0$1(_))(_=%3E$1(_)))))(_=%3E$0$0=%3EUndefined(_))(_=%3E$1=%3E$1(_))(_=%3EUndefined(_))(_=%3E$0$0=%3E$0$1=%3EUndefined(_)))(_=%3Econcat=%3E$D1(_)(_=%3Equicksort=%3E$0=%3E$0(_)(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3Econcat(_)(_=%3E(quicksort(_)(_=%3E$1$0(_))))(_=%3E(Cons(_)(_=%3E$0(_))(_=%3E(quicksort(_)(_=%3E$1$1(_))))))))(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3Econcat(_)(_=%3E(quicksort(_)(_=%3E$1$0(_))))(_=%3E(Cons(_)(_=%3E$0(_))(_=%3E(quicksort(_)(_=%3E$1$1(_))))))))(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3Econcat(_)(_=%3E(quicksort(_)(_=%3E$1$0(_))))(_=%3E(Cons(_)(_=%3E$0(_))(_=%3E(quicksort(_)(_=%3E$1$1(_))))))))(_=%3E$0$0=%3E$0$1=%3Equicksort(_)(_=%3E$0$0(_))(_=%3E(partition(_)(_=%3E$0$0(_))(_=%3E$0$1(_)))))(_=%3E$0$0=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3Econcat(_)(_=%3E(quicksort(_)(_=%3E$1$0(_))))(_=%3E(Cons(_)(_=%3E$0(_))(_=%3E(quicksort(_)(_=%3E$1$1(_))))))))(_=%3ENill(_))(_=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3Econcat(_)(_=%3E(quicksort(_)(_=%3E$1$0(_))))(_=%3E(Cons(_)(_=%3E$0(_))(_=%3E(quicksort(_)(_=%3E$1$1(_))))))))(_=%3E$0$0=%3E$0$1=%3E$1=%3E$1(_)(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3EUndefined(_))(_=%3E$1$0=%3EUndefined(_))(_=%3EUndefined(_))(_=%3EUndefined(_))(_=%3E$1$0=%3E$1$1=%3Econcat(_)(_=%3E(quicksort(_)(_=%3E$1$0(_))))(_=%3E(Cons(_)(_=%3E$0(_))(_=%3E(quicksort(_)(_=%3E$1$1(_)))))))))(_=%3Equicksort=%3E$D1(_)(_=%3Ev0=%3EZ(_))(_=%3Ev0=%3E$D1(_)(_=%3Ev1=%3ES(_)(_=%3Ev0(_)))(_=%3Ev1=%3E$D1(_)(_=%3Ev2=%3ES(_)(_=%3Ev1(_)))(_=%3Ev2=%3E$D1(_)(_=%3Ev3=%3ES(_)(_=%3Ev2(_)))(_=%3Ev3=%3E$D1(_)(_=%3Ev4=%3ES(_)(_=%3Ev3(_)))(_=%3Ev4=%3E$D1(_)(_=%3Elist=%3ECons(_)(_=%3Ev3(_))(_=%3E(Cons(_)(_=%3Ev4(_))(_=%3E(Cons(_)(_=%3Ev1(_))(_=%3E(Cons(_)(_=%3Ev0(_))(_=%3ENill(_)))))))))(_=%3Elist=%3Equicksort(_)(_=%3Elist(_))))))))))))))))))))))(_=%3E$0=%3Ec=%3E(f=%3Ec(_)(f))(_=%3E$Y(_)($0))))(_=%3E$0=%3Ec=%3Ec(_)($0)))(_=%3Ef=%3E(x=%3Ef(_)(_=%3Ex(x)))(x=%3Ef(_)(_=%3Ex(x))))) by entering `exec`. 

```
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

### Lazy evaluation
Since all code is compiled to JS lambdas in such a way that they emulate lazy evaluation, we can create infinite data such as the list of all naturals:
```
natsFrom x = Cons x (natsFrom (S x));
nats = natsFrom Z;
```

Now this infinite list can be treated as any other, and we can for instance use a function to get the first x elements:
```
firstX x Nill = Nill;
firstX Z (Cons head tail) = Nill;
firstX (S x) (Cons head tail) = Cons head (firstX x tail);

output firstX (S (S (S Z))) nats;
```

The above would output the list of the numbers 0, 1, and 2.

JavaScript's lambdas always first evaluate their arguments before executing the function, so it does not by default evaluate lazily. 
To fix this, the compiler is made to obey the convention that any variable will be a "getter" function of a value instead.

E.g. in JavaScript we would not write `(x=>x+1)(2)`, but instead would write `(x=>x(_)+1)(_=>2)`. So any value supplied as an argument is supplied as a function (with a redudant parameter) that returns the value. Then any location where a variable `x` is accessed, the `x` getter is applied to the `_` value. It's irrelevant what `_` is, since it's just a placeholder, but we usually make it the identity function: `_ = x=>x`.  

This convention is also the reason that applying arguments in JS to the compiled code is a little bit nasty. 
While usually we would write `console.log(decode(v))`, if `v` takes an argument, we have to write `console.log(decode(_=>v(_)(encode(arg))))`. This is because we have to pass our value lazily to `decode`, so we have to pass a getter function, and we have to first obtain the function `v` from the lazy getter, by applying it to our dummy variable `_`. Only then we can supply our argument to this, which we can create using a string and the encode function, E.g. `console.log(decode(_=>v(_)(encode("(S (S Z))"))))`.  

### Compilation process
This repository contains rascal code for compiling ljs code to lambda expressions in JS. See [VSCode integration](#VSCode-integration).

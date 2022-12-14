# Rascal remarks

This was my first project with Rascal, in order to familiarise myself with it. 
I kept track of my thoughts while using Rascal below, but note that all of these come from me not being informed. 
Some may be valid remarks/questions, while others may make no sense.

## Notes
- No type/checking intellisense at compiletime
- No syntax highlighting if grammar error (Quite annoying/difficult to discover that I can't used "start" as a variable for instance)
- Poor syntax error text (expected symbol, etc)
- `[type]: [value]` in terminal is a bit confusing
- In eclipse: Sometimes instant save, sometimes build dialog
- Visitor: top-down-break and bottom-up-break; Why not get this behavior more dynamically by using some sort of "break" statement?
- No lambda expressions, or function parameter signatures? 
- Is there tooling for source-maps, such as found in javascript? 
- No inline if? (it behaves like it's inline, but isn't syntactically an expression)
- What's the type of some syntax like `MySyntax*` and what operations does it have?
- Can I pattern match an entire syntax rule, instead of destructuring it? E.g. (Constructor)\`\<varName\>\`
- Weid behavior with replacements: https://puu.sh/Jm605/373f639d0d.png
- Transparency about runtime performance of functions, E.g. pattern matching iteration
- Multiple incorrect compile time errors, E.g. not finding that a function definition exists when overloaded
- When a syntax symbol can match 0 or more times, the pattern matching with a concrete syntax pattern breaks down 
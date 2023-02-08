This is a very simple webpage that allows you to execute compiled lambdaJS code.
It requires 2 query parameters to be present in the URL on page load in order to work:
- constructors: An ordered list of constructor names and their parameter count. E.g. `[["Z", 0], ["S", 1]]`
- func: The pure javascript lambda calculus function that the code compiled into
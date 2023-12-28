# Goal

I want to verify the correctness of TeX and/or Metafont. My expectation is that
I'll have to do the following: 

1. Recompile TeX/MF to the most modern dialect of Pascal (Free Pascal)
2. Export a Pascal AST from the Free Pascal Compiler (FPC)
3. Write a lifter program that reads in Pascal ASTs and writes out Gallina code
4. Ensure the Gallina code can be extracted to OCaml/Haskell code
5. Write correctness specifications for core operations
6. Verify the correctness of said operations

# Recompilation

Thankfully, TeX and MF have already been recompiled via the [`tex-fpc`](https://ctan.org/pkg/tex-fpc?lang=en)
package. I've included some scripts to smooth this process out.

# AST Export

This is trickier. FPC offers a flag `-vp` that dumps a parse tree to a file,
but it doesn't seem to contain all of the information I need. Namely, string
constants are not included in the output. Additionally, it seems like a very
complex output format.

# Lifter

Step 1 is the parser. This was very tedious, FPC's parse tree dump language is
awful (and it's been a long time since I've written a grammar this complex, I
really need to read up on LR(1) parsing again). I ran into a ton of menhir 
stability issues and bad error messages, and yacc isn't expressive enough for
a large part of the grammar, which is unfortunate because its conflict files are
paradoxically vastly easier to read than menhir's. Some of the grammar is 
context-sensitive, which I will have to delay to a custom parser later in the 
pipeline.

Parser has hit first milestone: I can parse a standard "Hello World" with an assignment
as well as an empty program. Next step: parsing mf and tex. After that, I can start
lifting into Gallina.

Parser has parsed the ASTs for TeX and MF! The grammar has a number of conflicts
and there are surely translation bugs but this is a huge milestone. Now that I
have an OCaml program that can read Pascal programs, I can begin to export Gallina 
code.

I've begun lifting. Initially, I thought to hook into the `coq-core` library in
order to utilize existing infrastructure for generating Coq ASTs. Unfortunately,
the library is devilishly complex, and I have yet to find a clean way to generate
even something as simple as a constant Definition vernacular. I've resorted to
implementing my own code generator, and I've found this to be conducive to quick
development. I feel uneasy about doing string generation on something this complex,
but I've decided I'll deal with those problems when I get to them. I'm currently
working on implementing imperative behavior, and the biggest issue is retrieving
from the store. Variables can have many types, so I'm left with a few options:

1. Have one store that contains all variable values. A sum type is required to
distinguish between them.
2. Have multiple stores, one for each type. This requires a much larger amount
of architectural design, and I think it will make for more difficult proof goals.

I prefer step 1. It has some issues: for example, I believe I'll need to check
for the presence of identifiers in the store for any statement that draws from 
the store. If any aren't present, the file must still compile, so the store is
forced to return a default value like 0, instead of making the store return
`option value`. As a saving grace, I can implement poison values, similar to how
LLVM prevents bad data from progressing through a program. At the beginning of
each statement, I can have something like:

```
let store, poison = 
    if all_present store [<id in expr 1>; <id in expr 2>; ... <id in expr n>]
    then
        <new store computation>, poison
    else 
        store, true 
    in
...
```

This way, computations just aren't performed if the program state is poisoned
by an undeclared identifier. The function can return a store and poison value,
and the poison should propagate all the way through the control flow. I like this
approach for a few reasons:

1. It will reduce in proof states very easily thanks to automatic reduction of
the `update` function
2. It can be expanded to a number of other errors, such as overflows that might
be bugs
3. It is a tangible target for verification (forall inputs, is_poisoned (f inputs) = false)

It does have a pretty annoying issue: I still have a store with a sum type, so if
I want to retrieve from it I have to have `get_int`, `get_string`, etc. functions
that DO contain a default value. This default value is never used thanks to our
poison check, but it's still required to compile.

I just realized I'll need a typing context so I know which get function to call...
ugh.

# Extraction

# Correctness

# Verification

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

# Extraction

# Correctness

# Verification

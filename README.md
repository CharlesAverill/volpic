# VOLPIC

![logo_black.png](media/logo_white.png)

VOLPIC, or "Verifier Of Lifted Pascal In Coq," is a platform for lifting 
[FPC](https://www.freepascal.org/)-compatible Pascal code into equivalent 
[Gallina](https://coq.inria.fr/doc/v8.9/refman/language/gallina-specification-language.html)
code, which can then be verified in the [Coq Proof Assistant](https://coq.inria.fr/) 
and [extracted](https://coq.inria.fr/doc/v8.9/refman/addendum/extraction.html)
into OCaml or Haskell code.

Read the [2024 PLDI SRC extended abstract](https://seashell.charles.systems/publications/VOLPIC_SRC.pdf)
for an explanation of the project's purpose, structure, and accomplishments. 

## Usage

First, build a custom version of FPC based on [my branch](https://gitlab.com/CharlesAverill/source/-/tree/volpic_fpc)*. 
Note, building the compiler requires an existing installation of FPC. 
Check out the [official installation guide](https://wiki.freepascal.org/Installing_the_Free_Pascal_Compiler).
Building my custom FPC should look like:

```bash
git clone https://gitlab.com/CharlesAverill/source/ fpc-source
cd fpc-source
git checkout volpic_fpc
cd compiler
make cycle -j8
```

The build will have completed if three binaries `ppc1`, `ppc2`, and `ppc3` have been generated, as well as the final compiler build, denoted by the architecture you built for (ex. `ppcx64`)

To compile and run the lifter:

```bash
git clone https://github.com/CharlesAverill/volpic
cd volpic/vp_lifter
opam install . --deps-only
make
dune exec vp_lifter -- <path_to_program> -fpc-path "<path-to-custom-fpc-source>/compiler/ppcx64" -fpc-args "-Fu<path-to-custom-fpc-source>/rtl/units/x86_64-linux/"
```

\* These changes are [merged into FPC main](https://gitlab.com/freepascal.org/fpc/source/-/merge_requests/567),
but due to the volatility of the parse tree dump format, I've
chosen to maintain my own fork of version 3.2.2.

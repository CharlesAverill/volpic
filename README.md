# VOLPIC

![logo_black.png](media/logo_white.png)

VOLPIC, or "Verifier Of Lifted Pascal In Coq," is a platform for lifting 
[FPC](https://www.freepascal.org/)-compatible Pascal code into equivalent 
[Gallina](https://coq.inria.fr/doc/v8.9/refman/language/gallina-specification-language.html)
code, which can then be verified in the [Coq Proof Assistant](https://coq.inria.fr/) 
and [extracted](https://coq.inria.fr/doc/v8.9/refman/addendum/extraction.html)
into OCaml or Haskell code.

## Usage

First build a custom version of FPC based on [my branch](https://gitlab.com/CharlesAverill/source/-/tree/add_parse_tree_info),
awaiting merge into FPC main.

```bash
cd vp_lifter
make
dune exec vp_lifter -- <path_to_program> -fpc-path "<path-to-custom-fpc-source>/compiler/ppcx64" -fpc-args "-Fu<path-to-custom-fpc-source>/rtl/units/x86_64-linux/"
```

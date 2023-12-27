# VOLPIC

![logo_black.png](media/logo_white.png)

VOLPIC, or "Verifier Of Lifted Pascal In Coq," is a platform for lifting 
[FPC](https://www.freepascal.org/)-compatible Pascal code into equivalent 
[Gallina](https://coq.inria.fr/doc/v8.9/refman/language/gallina-specification-language.html)
code, which can then be verified in the [Coq Proof Assistant](https://coq.inria.fr/) 
and [extracted](https://coq.inria.fr/doc/v8.9/refman/addendum/extraction.html)
into OCaml or Haskell code.

An example:
<table>
<tr>
<th>
Pascal
</th>
<th>
Coq
</th>
</tr>

<tr>

<td>
<pre>
program Print5;

var
	x: cardinal;

begin
	x := 5;
end.
</pre>
</td>

<td>
<pre>
From Volpic Require Import Volpic_preamble.
Require Import String.
Open Scope string_scope.
Definition main (VOLPIC_store : store) := 
        let VOLPIC_store := update VOLPIC_store "X" (Integer 5) in
        VOLPIC_store.
</pre>
</td>

</tr>
</table>

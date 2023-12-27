Definition x := let y := 5 in let y := 6 in y.
Compute x.

Definition test (_ : unit) := 5.

Compute test tt.



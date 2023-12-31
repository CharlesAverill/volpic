program Print5;

var
	x: cardinal;
	y: cardinal;

function test(y: cardinal) : cardinal;
var
	x : cardinal;
begin
	x := 99;
	test := x - 9;
end;

begin
	y := 6;
	x := 5 + y;
	x := test(y);
	writeln(x);
end.

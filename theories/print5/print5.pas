program Print5;

type
  fourquarters = packed record
    b0: cardinal;
    b1: cardinal;
    b2: string;
    b3: string;
  end;

var
	x: fourquarters;

function test: fourquarters;
var result : fourquarters;
begin
  result.b0 := 99;
  test.b0 := 9;
  test.b1 := 10;
  test.b2 := 'bye';
  test.b3 := 'world';
end;

begin
	x := test;
end.

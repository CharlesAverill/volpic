program Print5;

var
	x: cardinal;
  y: cardinal;

begin
  for x := 0 to 5 do
    y := x + y;
  for x := 5 downto 0 do
    y := x + y;
  writeln(y);
end.

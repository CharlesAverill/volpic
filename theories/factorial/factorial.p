program Factorial;

uses
    sysutils;

function factorial(x: integer) : integer;
begin
    factorial := 1;
    while 1 <= x do
    begin
        factorial := factorial * x;
        x := x - 1;
    end;
end;

var 
    i : string;
    n : integer;
begin
    write('n: ');
    readln(i);
    n := strtoint(i);

    writeln('fact(n): ', factorial(n));
end.

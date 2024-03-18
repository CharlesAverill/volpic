program PalindromeChecker;

// uses
//   SysUtils;

function IsPalindrome(str: string): boolean;
var
  i, len: integer;
begin
  IsPalindrome := True;

  len := Length(str);
  for i := 1 to len div 2 do
  begin
    if str[i] <> str[len - i + 1] then
    begin
      IsPalindrome := False;
      break;
    end;
  end;
end;

var
  inputStr: string;
begin
  // Read input from the user
  Write('Enter a string: ');
  Readln(inputStr);

  // Check if the input string is a palindrome
  if IsPalindrome(inputStr) then
    writeln('The string "', inputStr, '" is a palindrome.')
  else
    writeln('The string "', inputStr, '" is not a palindrome.');
end.

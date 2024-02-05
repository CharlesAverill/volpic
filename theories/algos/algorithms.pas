{$INLINE OFF}
program Algorithms;

uses
    sysutils;

type
    int_arr = array of integer;

var
    arr, sorted: int_arr;
    i: cardinal;
    key: integer;

procedure print_arr(arr : int_arr);
var
    i: cardinal;
begin
    write('[');
    for i := 0 to high(arr) do
    begin
        write(inttostr(arr[i]));
        if i <> high(arr) then
            write(', ');
    end;
    writeln(']');
end;

function bubble_sort(arr: int_arr) : int_arr;
var
    temp: integer;
    i, j: cardinal;
begin
    // Setup array
    setlength(bubble_sort, length(arr));
    for i := 0 to high(arr) do
    begin
        bubble_sort[i] := arr[i];
    end;
    
    // Do sort
    for i := high(bubble_sort) - 1 downto 0 do
    begin
        for j := 0 to i do 
        begin
            if bubble_sort[j] > bubble_sort[j + 1] then
            begin
                temp := bubble_sort[j];
                bubble_sort[j] := bubble_sort[j + 1];
                bubble_sort[j + 1] := temp;
            end;
        end;
    end;

    bubble_sort := bubble_sort;
end;

procedure simple_loop;
var
    i: cardinal;
begin
    for i := 0 to 10 do
        writeln(i);
end;

function linear_search(arr: int_arr; key: integer) : integer;
var
    i: integer;
begin
    linear_search := -1;

    for i := 0 to high(arr) do 
    begin
        if (arr[i] = key) then 
        begin
            linear_search := i;
            break;
        end;
    end;
end;

function binary_search(arr: int_arr; key: integer) : integer;
var
    l, r, m: cardinal;
begin
    l := 0;
    r := high(arr);

    binary_search := -1;

    while l <= r do
    begin
        m := l + (r - l) div 2;
        if (arr[m] = key) then 
        begin
            binary_search := m;
            break;
        end;

        if (arr[m] < key) then 
            l := m + 1
        else
            r := m - 1;
    end;
end;

begin
    // Initialize array with random elements
    setlength(arr, 100);
    for i := 0 to high(arr) do
        arr[i] := random(1000);

    // Get key to search for, should be random
    key := arr[50];

    // Sort array to lost index of 50
    sorted := bubble_sort(arr);

    // Linear search
    i := linear_search(sorted, key);
    writeln('Linear search:');
    writeln('  Key:        ', key);
    writeln('  Index:      ', i);
    writeln('  arr[index]: ', sorted[i]);

    // Binary search
    i := binary_search(sorted, key);
    writeln('Binary search:');
    writeln('  Key:        ', key);
    writeln('  Index:      ', i);
    writeln('  arr[index]: ', sorted[i]);
end.

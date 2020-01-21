type matrix = array 3 of array 3 of integer;

proc sum(proc f(t: integer): integer): integer;
begin
    return f(0) + f(1) + f(2)
end;

proc matsum(var a: matrix): integer;
    proc rowsum(i: integer): integer;
        proc cell(j: integer): integer;
        begin return a[i][j] end;
    begin
        return sum(cell)
    end;
begin
    return sum(rowsum)
end;

proc test();
    var a: matrix; i, j: integer;
begin
    for i := 0 to 2 do
        for j := 0 to 2 do
            a[i][j] := (i+1)*(j+1)
        end
    end;

    print_num(matsum(a)); newline()
end;

begin test() end.

(*<<
36
>>*)

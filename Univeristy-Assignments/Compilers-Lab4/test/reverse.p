type list = pointer to cell;
  cell = record head: char; tail: list end;

proc reverse(a: list): list;
  var p, q, r: list;
begin
  p := a; q := nil;
  while p <> nil do
    r := p^.tail; p^.tail := q;
    q := p; p := r
  end;
  return q
end;

proc test();
  const mike = "mike";

  var i: integer; p, q: list;
begin
  p := nil; i := 0; 
  while mike[i] <> chr(0) do
    new(q);
    q^.head := mike[i];
    q^.tail := p;
    p := q; i := i+1
  end;

  p := reverse(p);

  q := p;
  while q <> nil do
    print_char(q^.head);
    q := q^.tail
  end;
  newline()
end;

begin test() end.

(*<<
mike
>>*)

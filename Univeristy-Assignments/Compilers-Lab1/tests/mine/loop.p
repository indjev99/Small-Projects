begin
  loop
    x := x + 1;
    if x >= 10 then exit end;
    y := y + x;
    print x;
    print y;
    newline
  end
end.

begin
  i := 0;
  while i < 20 do
    if i mod 3 = 0 then
      print i
    elsif i mod 3 = 1 then
      print i - 1
    else
      print i - 2
    end;
    newline;
    i := i + 1;
  end
end.

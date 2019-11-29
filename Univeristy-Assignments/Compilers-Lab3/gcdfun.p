(* lab3/gcdfun.p *)

proc gcd(x, y);   
begin
  while x <> y do
    if x > y then
      x := x - y
    else
      y := y - x
    end
  end;
  return x
end;

begin
  print gcd(3*37, 7*37); newline
end.

(*<<
 37
>>*)

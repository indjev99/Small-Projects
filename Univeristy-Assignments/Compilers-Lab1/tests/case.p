begin
  i := 0;
  loop
    i := i + 1;
    case i mod 35 of
       0:
          print -350; newline;
          exit
      | 5, 10, 15, 20, 25, 30:
          print -50; newline
      | 7, 14, 21, 28:
          print -70; newline
    else
      print i; newline
    end
  end
end.

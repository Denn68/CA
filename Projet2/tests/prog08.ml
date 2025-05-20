let rec somme = fun x -> if eq(x, 0) then 0 else add(x, somme(sub(x, 1))) in somme(3)

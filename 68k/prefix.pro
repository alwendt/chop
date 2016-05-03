prefix([H|T],1,[H]).
prefix([X|L],N,[X|M]) :- Next is N-1, prefix(L,Next,M).

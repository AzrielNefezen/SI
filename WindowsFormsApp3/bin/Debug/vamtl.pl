:- use_module(library(clpfd)).
:- Dynamic edge/3.

len([],0).
len([_|T],N)  :-  len(T,X),  N  is  X+1.
 
atomDoZmiennejMapper(Var, R, Map1, Map2) :-
    nonvar(Map1)->
    przypiszNowaWartosc2(Var, R, Map1, Map2);
    przypiszNowaWartosc2(Var, R, [], []).
 
przypiszNowaWartosc2(Var, R, Map1, Map2):-
    member(Var,Map1)->
    wezAtomMapZmienna(Var, Map1, Map2, R);
    R = [NewVariable].
 
wezAtomMapZmienna(Var, Map1, Map2, R):-
    nth0(Index, Map1, Var),
    wezZmienna(Index, Map2, R).
 
wezZmienna(Index, Map, Wynik):-
    N = 0,
    wezZmienna(Index, Map, Wynik, N).
 
wezZmienna(Index, [H|T], Wynik, N):-
    Index = N ->
    Wynik = [H];
    N1 is N+1,
    wezZmienna(Index, T, Wynik, N1).
 
 
dodajDoListy(L,NL):-
    append(L, [], NL).
 
dodajDoListy(L1, L2, NL):-
    append(L1, L2, NL).
 
czyElementJestUnikalny([H|_], L2):-
    member(H, L2)->
    false;
    true.
 
dodajDoListyUstalonej(L1, L2, NL):-
    nonvar(L1)->
    (   nonvar(L2)->
        dodajDoListy(L2, L1, NL);
        dodajDoListy(L1, NL)
    );
    dodajDoListy(L2,NL).
 
mapaListyAtomow([], Vs, Vs, Map1, Map1, Map2, Map2).
mapaListyAtomow([], Vs, Vs, Map1Out, Map1In, Map2Out, Map2In, Map1Out, Map2Out).
 
mapaListyAtomow(Al,Vs,Map1,Map2,Map1out, Map2out):-
    N = 0,
    mapaListyAtomow(Al,TempVs,Vs, TempMap1, Map1, TempMap2, Map2, N, Map1out, Map2out).
 
mapaListyAtomow(List, TempVs, Vs, TempMap1, Map1, TempMap2, Map2, N, Map1out, Map2out):-
    (   N = 0 ->
    dodajDoListyUstalonej(Map1, TempMap1, TM1),
    dodajDoListyUstalonej(Map2, TempMap2, TM2),
    mapaListyAtomow(List, TempVs, Vs, TM1, Map1, TM2, Map2, Map1out, Map2out);
    true ).
 
 
mapaListyAtomow([AtomsH|AtomsT], TempVs, Vs, TempMap1, Map1, TempMap2, Map2, Map1out, Map2out):-
 
    atomDoZmiennejMapper(AtomsH, R, Map1, Map2),
    (czyElementJestUnikalny([AtomsH], TempMap1)->
    dodajDoListy([AtomsH], TempMap1, TMP1),
    dodajDoListy(R, TempMap2, TMP2);
    dodajDoListy(TempMap1, TMP1),
    dodajDoListy(TempMap2, TMP2)),
 
    %list_to_set(BufTMP1, TMP1),
 
 
    dodajDoListy(R,NL),
    dodajDoListy(TempVs,NL,VSNL),
    mapaListyAtomow(AtomsT, VSNL, Vs, TMP1, Map1, TMP2, Map2, Map1out, Map2out).
 
    findAdjacentEdgesForVertexIncludingVertex(V, R):-
    findall(X, (edge(V,Y,X) ; edge(Y,V,X)), Z),
    append([V], Z, R).
 
 
rozwiazVAMTL(L,Wynik):-
    N is 0,
    utworzSasiednieDlaWierzcholkow(L, OBuf, O),
    %writeln(O),
    przypiszAtomyDoListyList(O, VsOut, Map1Out, Map2Out),
    %writeln(VsOut),
    %writeln(Map1Out),
    %writeln(Map2Out),!,
    clpfd_equationSolver(Map2Out, VsOut, Map1Out, Wynik), !.
 
przypiszAtomyDoListyList(LoL, VsLoLOut, Map1Out, Map2Out):-
    przypiszAtomyDoListyList(LoL, VsLoLOut, Map1Out, Map2Out, VsBuf, Map1Buf, Map2Buf).
 
przypiszAtomyDoListyList([H|T], VsLoLOut, Map1Out, Map2Out, VsBuf, Map1Buf, Map2Buf):-
    mapaListyAtomow(H, Vs, Map1Buf, Map2Buf, Map1OutBuf, Map2OutBuf),
    (
        nonvar(VsBuf)->dodajDoListy([Vs], VsBuf, VsBufOut);
        dodajDoListy([Vs], VsBufOut)
    ),
    przypiszAtomyDoListyList(T, VsLoLOut, Map1Out, Map2Out, VsBufOut, Map1OutBuf, Map2OutBuf).
 
przypiszAtomyDoListyList([], VsLoLOut, Map1Out, Map2Out, VsLoLOut, Map1Out, Map2Out).
 
utworzSasiednieDlaWierzcholkow([H|T], OBuf, O):-
    findAdjacentEdgesForVertexIncludingVertex(H, R),
    (
        nonvar(OBuf)-> dodajDoListy([R], OBuf, R1);
        R1 = [R]
    ),
    utworzSasiednieDlaWierzcholkow(T, R1, O).
 
utworzSasiednieDlaWierzcholkow([],O, O).
 
clpfd_equationSolver(L, LoL, WL,Wynik):-
    len(L, N),
    L ins 1..N,
    all_different(L),
    sumujWszystkie(LoL, S),
    label(L),
    %writeln(WL), !,
    Wynik = [WL|[L]].
    %writeln(L), !.
    %writeln(S).
 
sumuj(L, S):-
    sum(L, #\=, S),
    label(L),
    sum_list(L, Sum).
 
sumujWszystkie([H|T], S):-
    sumuj(H,S),
    sumujWszystkie(T, S).
 
sumujWszystkie([], S).
 
startVAMTL(Lines,Wynik):-
    %writeln(Lines),
    zbudujasserts(Lines, L),!,
    rozwiazVAMTL(L, Wynik),
    retractall(edge(_,_,_)).
 
zbudujasserts([H|T], L):-
    assert(H),
    zbudujasserts(T, L).
 
zbudujasserts([H,_], H).
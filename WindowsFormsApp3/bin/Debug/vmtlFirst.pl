:- use_module(library(clpfd)).
:- Dynamic edge/3.

len([],0).
len([_|T],N)  :-  len(T,X),  N  is  X+1.
 
atomToVariableMapper(Var, R, Map1, Map2) :-
    nonvar(Map1)->
    assignNewVariableIfNotMember(Var, R, Map1, Map2);
    assignNewVariableIfNotMember(Var, R, [], []).
 
assignNewVariableIfNotMember(Var, R, Map1, Map2):-
    member(Var,Map1)->
    getAtomMapVariable(Var, Map1, Map2, R);
    R = [NewVariable].
 
getAtomMapVariable(Var, Map1, Map2, R):-
    nth0(Index, Map1, Var),
    getVariable(Index, Map2, R).
 
getVariable(Index, Map, Result):-
    N = 0,
    getVariable(Index, Map, Result, N).
 
getVariable(Index, [H|T], Result, N):-
    Index = N ->
    Result = [H];
    N1 is N+1,
    getVariable(Index, T, Result, N1).
 
 
addToList(L,NL):-
    append(L, [], NL).
 
addToList(L1, L2, NL):-
    append(L1, L2, NL).
 
isAddingElementUnique([H|_], L2):-
    member(H, L2)->
    false;
    true.
 
addToListIfInstantiated(L1, L2, NL):-
    nonvar(L1)->
    (   nonvar(L2)->
        addToList(L2, L1, NL);
        addToList(L1, NL)
    );
    addToList(L2,NL).
 
mapAtomList([], Vs, Vs, Map1, Map1, Map2, Map2).
mapAtomList([], Vs, Vs, Map1Out, Map1In, Map2Out, Map2In, Map1Out, Map2Out).
 
mapAtomList(Al,Vs,Map1,Map2,Map1out, Map2out):-
    N = 0,
    mapAtomList(Al,TempVs,Vs, TempMap1, Map1, TempMap2, Map2, N, Map1out, Map2out).
 
mapAtomList(List, TempVs, Vs, TempMap1, Map1, TempMap2, Map2, N, Map1out, Map2out):-
    (   N = 0 ->
    addToListIfInstantiated(Map1, TempMap1, TM1),
    addToListIfInstantiated(Map2, TempMap2, TM2),
    mapAtomList(List, TempVs, Vs, TM1, Map1, TM2, Map2, Map1out, Map2out);
    true ).
 
 
mapAtomList([AtomsH|AtomsT], TempVs, Vs, TempMap1, Map1, TempMap2, Map2, Map1out, Map2out):-
 
    atomToVariableMapper(AtomsH, R, Map1, Map2),
    (isAddingElementUnique([AtomsH], TempMap1)->
    addToList([AtomsH], TempMap1, TMP1),
    addToList(R, TempMap2, TMP2);
    addToList(TempMap1, TMP1),
    addToList(TempMap2, TMP2)),
 
    %list_to_set(BufTMP1, TMP1),
 
 
    addToList(R,NL),
    addToList(TempVs,NL,VSNL),
    mapAtomList(AtomsT, VSNL, Vs, TMP1, Map1, TMP2, Map2, Map1out, Map2out).
 
    findAdjacentEdgesForVertexIncludingVertex(V, R):-
    findall(X, (edge(V,Y,X) ; edge(Y,V,X)), Z),
    append([V], Z, R).
 
 
solveVMTL(L,Result):-
    N is 0,
    composeAllAdjacentsForAllVertexes(L, OBuf, O),
    %writeln(O),
    composeAllMapAtomListForEveryListOfLists(O, VsOut, Map1Out, Map2Out),
    %writeln(VsOut),
    %writeln(Map1Out),
    %writeln(Map2Out),!,
    clpfd_equationSolver(Map2Out, VsOut, Map1Out, Result), !.
 
composeAllMapAtomListForEveryListOfLists(LoL, VsLoLOut, Map1Out, Map2Out):-
    composeAllMapAtomListForEveryListOfLists(LoL, VsLoLOut, Map1Out, Map2Out, VsBuf, Map1Buf, Map2Buf).
 
composeAllMapAtomListForEveryListOfLists([H|T], VsLoLOut, Map1Out, Map2Out, VsBuf, Map1Buf, Map2Buf):-
    mapAtomList(H, Vs, Map1Buf, Map2Buf, Map1OutBuf, Map2OutBuf),
    (
        nonvar(VsBuf)->addToList([Vs], VsBuf, VsBufOut);
        addToList([Vs], VsBufOut)
    ),
    composeAllMapAtomListForEveryListOfLists(T, VsLoLOut, Map1Out, Map2Out, VsBufOut, Map1OutBuf, Map2OutBuf).
 
composeAllMapAtomListForEveryListOfLists([], VsLoLOut, Map1Out, Map2Out, VsLoLOut, Map1Out, Map2Out).
 
composeAllAdjacentsForAllVertexes([H|T], OBuf, O):-
    findAdjacentEdgesForVertexIncludingVertex(H, R),
    (
        nonvar(OBuf)-> addToList([R], OBuf, R1);
        R1 = [R]
    ),
    composeAllAdjacentsForAllVertexes(T, R1, O).
 
composeAllAdjacentsForAllVertexes([],O, O).
 
clpfd_equationSolver(L, LoL, WL,Result):-
    len(L, N),
    L ins 1..N,
    all_different(L),
    sumAll(LoL, S),
    label(L),
    %writeln(WL), !,
    Result = [WL|[L]].
    %writeln(L), !.
    %writeln(S).
 
sumSingle(L, S):-
    sum(L, #\=, S),
    label(L),
    sum_list(L, Sum).
 
sumAll([H|T], S):-
    sumSingle(H,S),
    sumAll(T, S).
 
sumAll([], S).
 
startVMTLSolvingProcess(Lines,Result):-
    %writeln(Lines),
    buildAssertsFromFile(Lines, L),!,
    solveVMTL(L, Result),
    retractall(edge(_,_,_)).
 
buildAssertsFromFile([H|T], L):-
    assert(H),
    buildAssertsFromFile(T, L).
 
buildAssertsFromFile([H,_], H).
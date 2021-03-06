%-----------------------------------------------------------------------------------------------------------------------

xlast([X], X).
xlast([_|X],Y) :- xlast(X,Y).

xexcept_last([_],[]).
xexcept_last([F|L1],[F|L2]) :- xexcept_last(L1, L2).

xreverse([],[]).
xreverse(L1,[F2|L2]) :- xexcept_last(L1, X),xreverse(X,L2),xlast(L1,F2).

%-----------------------------------------------------------------------------------------------------------------------

xlists_equal([],[]).
xlists_equal([F1|L1],[F2|L2]) :- F1 = F2,xlists_equal(L1,L2).

xappend_value_to_front(L1, X, [F2|L2]) :- X = F2,xlists_equal(L1,L2).

xremove_all([],_,[]).
xremove_all([F|L1],X,L2) :- xremove_all(L1,X,Y),F \== X,xappend_value_to_front(Y,F,Z),L2=Z.
xremove_all([F|L1],X,L2) :- xremove_all(L1,X,Y),F == X,L2=Y.

xunique([],[]).
xunique([F|L1],L2) :- xunique(L1,X),xremove_all(X,F,Y),xappend_value_to_front(Y,F,Z),L2=Z.

%-----------------------------------------------------------------------------------------------------------------------

xappend([], X, X).
xappend([A|L1], L2, [A|L3]) :- xappend(L1,L2,L3).

xremove_all_from_list([],_,[]).
xremove_all_from_list(X,[],X).
xremove_all_from_list(L1,[F2|L2],L3) :- xremove_all_from_list(L1,L2,X),xremove_all(X,F2,Y),L3=Y.

xunion([],[],[]).
xunion(L1,L2,L3) :- xunique(L1,X),xunique(L2,Y),xremove_all_from_list(Y,X,Z),xappend(X,Z,A),L3=A.

%-----------------------------------------------------------------------------------------------------------------------

removeLast([X],[],X).
removeLast([F|L1],[F|L2],L3) :- removeLast(L1,L2,L3).

%-----------------------------------------------------------------------------------------------------------------------

isConnected(_,[]).
isConnected(X,[F|L]) :- edge(X,F),isConnected(X,L).
isConnected(X,[F|L]) :- edge(F,X),isConnected(X,L).

allConnected([]).
allConnected([F|L]) :- isConnected(F,L),allConnected(L).

subset([], _).
subset([X|Xs], Set) :-
  xappend(_, [X|Set1], Set),
  subset(Xs, Set1).

clique(L) :- findall(X,node(X),Nodes),
             subset(L,Nodes), allConnected(L).

xcount([],0).
xcount([_|L],X) :- xcount(L,Y),X is 1 + Y.

xcount_instances([],_,0).
xcount_instances([F|L],X,Y) :- F == X,xcount_instances(L,X,Z),Y is Z + 1.
xcount_instances([F|L],X,Y) :- F \== X,xcount_instances(L,X,Y).

xnot_contains([],_).
xnot_contains([F|L],X) :- F \== X,xnot_contains(L,X).

xcontains_clique([],_).
xcontains_clique([F1|Clique1], Clique2) :- xcount_instances(Clique2,F1,X),X == 1,xcontains_clique(Clique1,Clique2).

xnot_contains_clique([],X) :- X \== X. % ensure the result is false
xnot_contains_clique([F1|_],Clique2) :- xnot_contains(Clique2,F1).
xnot_contains_clique([_|Clique1],Clique2) :- xnot_contains_clique(Clique1,Clique2).

xmaximal_h(_,[]).
xmaximal_h(Clique,[F|L]) :- xnot_contains_clique(Clique,F),xmaximal_h(Clique,L).

xmaximal(Clique,Cliques) :- xremove_all(Cliques,Clique,L),xmaximal_h(Clique,L).

xnot_maximal_h(X,[]) :- X \== X. % ensure the result is false
xnot_maximal_h(Clique,[F|_]) :- xcontains_clique(Clique,F).
xnot_maximal_h(Clique,[F|L]) :- xnot_contains_clique(Clique,F),xnot_maximal_h(Clique,L).

xnot_maximal(Clique,Cliques) :- xremove_all(Cliques,Clique,L),xnot_maximal_h(Clique,L).

for_each_clique(_,[],_,[]).
for_each_clique(L1,[F2|L2],N,X) :- for_each_clique(L1,L2,N,Y),
                                xmaximal(F2,L1),
                                xcount(F2,Z),
                                Z == N,
                                xappend_value_to_front(Y,F2,A),
                                X = A.
for_each_clique(L1,[_|L2],N,X) :- for_each_clique(L1,L2,N,Y),
                                X = Y.

xfilter_cliques_by_size([],_,[]).
xfilter_cliques_by_size([F|Cliques],N,L) :- xfilter_cliques_by_size(Cliques,N,X),
                                            xcount(F,Y),
                                            Y @>= N,
                                            xappend_value_to_front(X,F,Z),
                                            L = Z.
xfilter_cliques_by_size([F|Cliques],N,L) :- xfilter_cliques_by_size(Cliques,N,X),
                                            xcount(F,Y),
                                            Y @< N,
                                            L = X.

maxclique(N,Cliques) :- findall(X,clique(X),L),
                        xremove_all(L,[],Y),
                        xfilter_cliques_by_size(Y,N,Z),
                        for_each_clique(Z,Z,N,X),
                        Cliques = X.

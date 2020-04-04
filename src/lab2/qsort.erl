%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. kwi 2020 11:19
%%%-------------------------------------------------------------------
-module(qsort).
-author("Lenovo").

%% API
-export([lessThan/2, grtEqThan/2, qs/1, randomElems/3, compareSpeeds/3]).

lessThan(List, Arg) -> [X || X <- List, X < Arg].

grtEqThan(List, Arg) -> [X || X <- List, X >= Arg].

qs([]) -> [];
qs([Pivot|Tail]) -> qs(lessThan(Tail,Pivot)) ++ [Pivot] ++ qs(grtEqThan(Tail,Pivot)).

randomElems(N, Min, Max) -> [rand:uniform(Max - Min + 1) + Min - 1 || _ <- lists:seq(1, N)].

compareSpeeds(List, Fun1, Fun2) ->
  {T1, _} = timer:tc(Fun1, [List]),
  {T2, _} = timer:tc(Fun2, [List]),
  io:format("first sorting function: ~p ms ~n second sorting function: ~p ms ~n", [T1,T2]).
-module(myLists).

-export([contains/2, duplicateElements/1, sumFloats/1]).

contains([], _) ->
  false;
contains([H | T], H) ->
  true;
contains([_ | T], V) ->
  contains(T, V).

duplicateElements([]) ->
  [];
duplicateElements([H | []]) ->
  [H | [H]];
duplicateElements([H | T]) ->
  [H | [H | duplicateElements(T)]].

sumFloats([]) ->
  0.0;
sumFloats([H | T])  when is_float(H) ->
  H + sumFloats(T);
sumFloats([_ | T]) ->
  sumFloats(T).

sumFloatsTail([], Sum) ->
  Sum;
sumFloatsTail([H | T], Sum) when is_float(H) ->
  sumFloatsTail(T, Sum + H);
sumFloatsTail([_ | T], Sum) ->
  sumFloatsTail(T, Sum).






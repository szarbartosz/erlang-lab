%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. kwi 2020 22:20
%%%-------------------------------------------------------------------
-module(onp).
-author("Lenovo").

%% API
-export([calculator/1]).

parse(String) ->
  case string:to_float(String) of
    {error, no_float} -> list_to_integer(String) * 1.0;
    {X, _} -> X
  end.

calculator(Formula) -> calculate(string:tokens(Formula, " "), []).

calculate([], [H | []]) -> H;
calculate(["+" | T1], [X, Y | T2]) -> calculate(T1, [X + Y | T2]);
calculate(["-" | T1], [X, Y | T2]) -> calculate(T1, [Y - X | T2]);
calculate(["*" | T1], [X, Y | T2]) -> calculate(T1, [X * Y | T2]);
calculate(["/" | T1], [X, Y | T2]) -> calculate(T1, [Y / X | T2]);
calculate(["sqrt" | T1], [X | T2]) -> calculate(T1, [math:sqrt(X) | T2]);
calculate(["pow" | T1], [X, Y | T2]) -> calculate(T1, [math:pow(Y, X) | T2]);
calculate(["sin" | T1], [X | T2]) -> calculate(T1, [math:sin(X) | T2]);
calculate(["cos" | T1], [X | T2]) -> calculate(T1, [math:cos(X) | T2]);
calculate(["double" | T1], [X | T2]) -> calculate(T1, [X * 2 | T2]);
calculate(["pit" | T1], [X, Y | T2]) -> calculate(T1, [math:pow(X, 2) + math:pow(Y, 2) | T2]);
calculate([H | T1], Stack) -> calculate(T1, [parse(H) | Stack]).
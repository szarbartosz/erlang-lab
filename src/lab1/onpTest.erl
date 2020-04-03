-module(onpTest).

-export([onp/1]).

onp(List) -> onpStack(List, []).

onpStack([], [Top]) -> Top;
onpStack([H | T], Stack) ->
  case is_integer(H) or is_float(H) of
    true -> onpStack(T, [H | Stack]);
    false -> onpStackOperator([H | T], Stack)
  end.

onpStackOperator([H | T], [L1, L2 | Stack]) ->
  if H == "+" ->
       onpStack(T, [L1 + L2 | Stack]);
     H == "-" ->
       onpStack(T, [L1 - L2 | Stack]);
    H == "*" ->
      onpStack(T, [L1 * L2 | Stack]);
    H == "/" ->
      onpStack(T, [L1 / L2 | Stack])
  end.

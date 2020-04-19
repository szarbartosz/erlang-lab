-module(onp).
-author("Lenovo").
-export([onp/1]).

onp(S) -> onpStack(string:tokens(S, " "), []).

onpStack([], [Stack]) -> Stack;
onpStack([H | T], Stack) ->
  case re:run(H, "^[0-9]*$") /= nomatch of
    true -> onpStack(T, [list_to_integer(H) | Stack]);
    false -> case re:run(H, "^[0-9]+[.][0-9]+$") /= nomatch of
               true -> onpStack(T, [list_to_float(H) | Stack]);
               false -> onpStackOperator([H | T], Stack)
             end
  end.

onpStackOperator(["+" | T], [S1, S2 | Stack]) ->
  onpStack(T, [S1 + S2 | Stack]);
onpStackOperator(["-" | T], [S1, S2 | Stack]) ->
  onpStack(T, [S2 - S1 | Stack]);
onpStackOperator(["*" | T], [S1, S2 | Stack]) ->
  onpStack(T, [S1 * S2 | Stack]);
onpStackOperator(["/" | T], [S1, S2 | Stack]) ->
  onpStack(T, [S2 / S1 | Stack]);
onpStackOperator(["pow" | T], [S1, S2 | Stack]) ->
  onpStack(T, [math:pow(S2, S1) | Stack]);
onpStackOperator(["sqrt" | T], [S | Stack]) ->
  onpStack(T, [math:sqrt(S) | Stack]);
onpStackOperator(["sin" | T], [S | Stack]) ->
  onpStack(T, [math:sin(math:pi() * S / 180) | Stack]);
onpStackOperator(["cos" | T], [S | Stack]) ->
  onpStack(T, [math:cos(math:pi() * S / 180) | Stack]);
onpStackOperator(["tan" | T], [S | Stack]) ->
  onpStack(T, [math:tan(math:pi() * S / 180) | Stack]);
onpStackOperator(["double" | T], [S | Stack]) ->
  onpStack(T, [S * 2 | Stack]);
onpStackOperator(["avg" | T], [S1, S2 | Stack]) ->
  onpStack(T, [(S1 + S2) / 2 | Stack]).
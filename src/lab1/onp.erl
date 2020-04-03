-module(onp).
-author("Barto.sz").

-export([onp/1]).

onp(List) -> onpStack(string:tokens(List, " "), []).

onpStack([], [Stack]) ->
  Stack;
onpStack([H | T], Stack) ->
  case lists:member(H, ["0","1","2","3","4","5","6","7","8","9","-1","-2","-3","-4","-5","-6","-7","-8","-9"]) of
    true -> onpStack(T, [list_to_integer(H) | Stack]);
    false -> case lists:member(H, ["+","-","*","/","pow","veclen"]) of
               true -> binaryOperator([H | T], Stack);
               false -> unaryOperator([H | T], Stack)
             end
  end.

binaryOperator([H | T], [T1, T2 | Stack]) ->
  if H == "+" ->
      onpStack(T, [T1 + T2 | Stack]);
    H == "-" ->
      onpStack(T, [T1 - T2 | Stack]);
    H == "*" ->
      onpStack(T, [T1 * T2 | Stack]);
    H == "/" ->
      onpStack(T, [T1 / T2 | Stack]);
    H == "pow" ->
      onpStack(T, [list_to_integer(float_to_list(math:pow(T1, T2),[{decimals,0}])) | Stack]);
    H == "veclen" ->
      onpStack(T, [list_to_integer(float_to_list(veclen(T1, T2),[{decimals,0}])) | Stack])
  end.

unaryOperator([H | T], [T1| Stack]) ->
  if H == "sqrt" ->
      onpStack(T, [list_to_integer(float_to_list(math:sqrt(T1),[{decimals,0}])) | Stack]);
    H == "sin" ->
      onpStack(T, [list_to_integer(float_to_list(math:sin(T1),[{decimals,0}])) | Stack]);
    H == "cos" ->
      onpStack(T, [list_to_integer(float_to_list(math:cos(T1),[{decimals,0}])) | Stack]);
    H == "tg" ->
      onpStack(T, [list_to_integer(float_to_list(math:tan(T1),[{decimals,0}])) | Stack]);
    H == "increment" ->
      onpStack(T, [increment(T1) | Stack])
  end.

veclen(X, Y) ->
  math:sqrt(math:pow(X,2) + math:pow(Y,2)).

increment(A) ->
  A + 1.
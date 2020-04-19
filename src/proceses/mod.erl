%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. kwi 2020 18:47
%%%-------------------------------------------------------------------
-module(mod).
-author("Lenovo").

%% API
-export([createAndAsk/0, reply/0]).

createAndAsk() ->
  Pid = spawn(mod, reply, []),
  Pid ! {self(), question},
  receive
    answer -> io:format("Received!")
  end.

reply() ->
  receive
    {Pid, question} -> Pid ! answer
  end.

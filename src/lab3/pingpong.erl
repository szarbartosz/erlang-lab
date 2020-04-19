%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. kwi 2020 19:41
%%%-------------------------------------------------------------------
-module(pingpong).
-author("Lenovo").

%% API
-export([start/0, stop/0, play/1]).

start() ->
  register(ping, spawn(fun() -> ping(0) end)),
  register(pong, spawn(fun() -> pong() end)).

stop() ->
  ping ! kill,
  pong ! kill.

play(N) ->
  ping ! {pong, N}.

ping(N) ->
  receive
    {Pid, Hits} ->
      case Hits > 0 of
        true -> io:format("Ping has bounced the ball bounced! ~w bounces left.~n Total no of bounces: ~w~n", [Hits - 1, N + 1]),
          timer:sleep(1000),
          Pid ! {self(), Hits - 1},
          ping(N + 1);
        false -> io:format("Game finished!~n")
      end;
    kill -> io:format("Game interrupted!~n"), ok
  after
    20000 -> io:format("Ping has left the game!~n"), ok
  end.

pong() ->
  receive
    {Pid, Hits} ->
      case Hits > 0 of
        true -> io:format("Ping has bounced the ball bounced! ~w bounces left.~n", [Hits - 1]),
          timer:sleep(1000),
          Pid ! {self(), Hits - 1},
          pong();
        false -> io:format("Game finished!~n")
      end;
    kill -> io:format("Game interrupted!~n"), ok
  after
    20000 -> io:format("Pong has left the game!~n"), ok
  end.

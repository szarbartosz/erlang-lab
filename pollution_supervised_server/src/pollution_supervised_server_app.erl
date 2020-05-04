%%%-------------------------------------------------------------------
%% @doc pollution_supervised_server public API
%% @end
%%%-------------------------------------------------------------------

-module(pollution_supervised_server_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    pollution_supervised_server_sup:start_link().

stop(_State) ->
    ok.

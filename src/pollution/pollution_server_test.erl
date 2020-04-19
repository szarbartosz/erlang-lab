%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. kwi 2020 22:47
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-author("Lenovo").

-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

%% API
-export([]).

start_test() ->
  pollution_server:start(),
  ?assert(lists:member(pollutionServer, registered())).

addStation_test() ->
  ?assertEqual(ok, pollution_server:addStation("station 1", {1, 1})),
  ?assertEqual({error, station_already_registered}, pollution_server:addStation("station 1", {2, 2})),
  ?assertEqual({error, station_already_registered}, pollution_server:addStation("station 2", {1, 1})),
  ?assertEqual(ok, pollution_server:addStation("station 2", {2, 2})).

addValue_test() ->
  ?assertEqual(ok, pollution_server:addValue("station 1", calendar:local_time(), "PM 10", 12)),
  ?assertEqual({error, measurement_already_registered}, pollution_server:addValue("station 1", calendar:local_time(), "PM 10", 12)),
  ?assertEqual({error, station_not_registered}, pollution_server:addValue("station 3", calendar:local_time(), "PM 10", 12)),
  ?assertEqual(ok, pollution_server:addValue("station 1", calendar:local_time(), "PM 5", 12)).
  ?assertEqual(ok, pollution_server:addValue("station 2", calendar:local_time(), "temperature", 18)).


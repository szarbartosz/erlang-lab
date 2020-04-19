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
  ?assertEqual(ok, pollution_server:addStation("station 2", {2, 2})),
  ?assertEqual(ok, pollution_server:addStation("station 4", {4, 4})).

addValue_test() ->
  ?assertEqual(ok, pollution_server:addValue("station 1", calendar:local_time(), "PM 10", 12)),
  ?assertEqual({error, measurement_already_registered}, pollution_server:addValue("station 1", calendar:local_time(), "PM 10", 12)),
  ?assertEqual({error, station_not_registered}, pollution_server:addValue("station 3", calendar:local_time(), "PM 10", 12)),
  ?assertEqual(ok, pollution_server:addValue("station 1", calendar:local_time(), "PM 5", 12)),
  ?assertEqual(ok, pollution_server:addValue("station 2", calendar:local_time(), "temperature", 18)),
  ?assertEqual(ok, pollution_server:addValue("station 1", {{2018, 04, 12}, {12, 56, 04}}, "temperature", 32)),
  ?assertEqual(ok, pollution_server:addValue("station 4", calendar:local_time(), "temperature", 20)).

removeValue_test() ->
  ?assertEqual(ok, pollution_server:removeValue("station 1", {{2018, 04, 12}, 12}, "temperature")),
  ?assertEqual({error, measurement_does_not_exist}, pollution_server:removeValue("station 1", {{2021, 04, 12}, 15}, "PM 10")).

getOneValue_test() ->
  {{Y, M, D}, {H, _, _}} = calendar:local_time(),
  ?assertEqual(12, pollution_server:getOneValue({1,1}, {{Y, M, D}, H}, "PM 10")),
  ?assertEqual({error, measurement_does_not_exist}, pollution_server:getOneValue({1,1}, {{Y, M, D}, H}, "PM 25")).

getStationMean_test() ->
  ?assertEqual(12.0, pollution_server:getStationMean({1, 1}, "PM 10")),
  ?assertEqual(18.0, pollution_server:getStationMean("station 2", "temperature")).

getDailyMean_test() ->
  {{Y, M, D}, _} = calendar:local_time(),
  ?assertEqual(19.0, pollution_server:getDailyMean("temperature", {Y, M, D})),
  ?assertEqual({error, incorrect_date}, pollution_server:getDailyMean("PM 10", {2021, 13, 43})).

getMonthlyMean_test() ->
  {{Y, M, _}, _} = calendar:local_time(),
  ?assertEqual(12.0, pollution_server:getMonthlyMean("PM 5", {Y, M})),
  ?assertEqual(19.0, pollution_server:getMonthlyMean("temperature", {Y, M})).

getExceededMeasurements() ->
  {{Y, M, D}, _} = calendar:local_time(),
  ?assertEqual(1, pollution_server:getExceededMeasurements("PM 10", {Y, M, D}, 5)),
  ?assertEqual(2, pollution_server:getExceededMeasurements("temperature", {Y, M, D}, 10)).

stop_test() ->
  ?assertEqual(stop, pollution_server:stop()),
  timer:sleep(100),
  ?assert(not lists:member(pollutionServer, registered())).

test_all() ->
  start_test(),
  addStation_test(),
  addValue_test(),
  removeValue_test(),
  getOneValue_test(),
  getStationMean_test(),
  getDailyMean_test(),
  getMonthlyMean_test(),
  getExceededMeasurements(),
  stop_test().
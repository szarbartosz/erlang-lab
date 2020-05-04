%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. maj 2020 21:31
%%%-------------------------------------------------------------------
-module(polluiton_gen_server_test).
-author("szarb").

-include_lib("eunit/include/eunit.hrl").

startLink_test() ->
  pollution_gen_server:start_link(),
  ?assert(lists:member(pollution_gen_server, registered())).

addStation_test() ->
  ?assertEqual(ok, pollution_gen_server:addStation("station 1", {1, 1})),
  ?assertEqual(ok, pollution_gen_server:addStation("station 2", {2, 2})),
  ?assertEqual(ok, pollution_gen_server:addStation("station 3", {3, 3})),
  ?assertEqual(ok, pollution_gen_server:addStation("station 4", {4, 4})).

addValue_test() ->
  ?assertEqual(ok, pollution_gen_server:addValue("station 1", calendar:local_time(), "PM 10", 12)),
  ?assertEqual(ok, pollution_gen_server:addValue({1, 1}, calendar:local_time(), "PM 5", 12)),
  ?assertEqual(ok, pollution_gen_server:addValue("station 2", calendar:local_time(), "PM 10", 16)),
  ?assertEqual(ok, pollution_gen_server:addValue({2, 2}, calendar:local_time(), "PM 5", 20)),
  ?assertEqual(ok, pollution_gen_server:addValue("station 3", calendar:local_time(), "temperature", 18)),
  ?assertEqual(ok, pollution_gen_server:addValue({3, 3}, {{2018, 04, 12}, {12, 56, 04}}, "temperature", 32)),
  ?assertEqual(ok, pollution_gen_server:addValue("station 4", calendar:local_time(), "temperature", 18)),
  ?assertEqual(ok, pollution_gen_server:addValue({4, 4}, {{2018, 04, 12}, {12, 56, 04}}, "temperature", 30)).

getOneValue_test() ->
  {{Y, M, D}, {H, _, _}} = calendar:local_time(),
  ?assertEqual(12, pollution_gen_server:getOneValue({1,1}, {{Y, M, D}, H}, "PM 10")),
  ?assertEqual({error, measurement_does_not_exist}, pollution_gen_server:getOneValue({1,1}, {{Y, M, D}, H}, "PM 25")),
  ?assertEqual(32, pollution_gen_server:getOneValue({3, 3}, {{2018, 04, 12}, 12}, "temperature")),
  ?assertEqual(18, pollution_gen_server:getOneValue("station 3", {{Y, M, D}, H}, "temperature")),
  ?assertEqual(12, pollution_gen_server:getOneValue("station 1", {{Y, M, D}, H}, "PM 5")).

getStationMean_test() ->
  ?assertEqual(12.0, pollution_gen_server:getStationMean({1, 1}, "PM 10")),
  ?assertEqual(16.0, pollution_gen_server:getStationMean("station 2", "PM 10")),
  ?assertEqual(16.0, pollution_gen_server:getStationMean({2, 2}, "PM 10")),
  ?assertEqual(24.0, pollution_gen_server:getStationMean("station 4", "temperature")).

getDailyMean_test() ->
  {{Y, M, D}, _} = calendar:local_time(),
  ?assertEqual(31.0, pollution_gen_server:getDailyMean("temperature", {2018, 04, 12})),
  ?assertEqual(16.0, pollution_gen_server:getDailyMean("PM 5", {Y, M, D})),
  ?assertEqual(14.0, pollution_gen_server:getDailyMean("PM 10", {Y, M, D})).

getMonthlyMean_test() ->
  {{Y, M, _}, _} = calendar:local_time(),
  ?assertEqual(31.0, pollution_gen_server:getMonthlyMean("temperature", {2018, 04})),
  ?assertEqual(16.0, pollution_gen_server:getMonthlyMean("PM 5", {Y, M})),
  ?assertEqual(14.0, pollution_gen_server:getMonthlyMean("PM 10", {Y, M})).

getExceededMeasurements_test() ->
  {{Y, M, D}, _} = calendar:local_time(),
  ?assertEqual(2, pollution_gen_server:getExceededMeasurements("PM 10", {Y, M, D}, 5)),
  ?assertEqual(2, pollution_gen_server:getExceededMeasurements("temperature", {Y, M, D}, 10)),
  ?assertEqual(0, pollution_gen_server:getExceededMeasurements("PM 5", {Y, M, D}, 30)),
  ?assertEqual(1, pollution_gen_server:getExceededMeasurements("PM 5", {Y, M, D}, 14)).

removeValue_test() ->
  {{Y, M, D}, {H, _, _}} = calendar:local_time(),
  ?assertEqual(ok, pollution_gen_server:removeValue({1, 1}, {{Y, M, D}, H}, "PM 10")),
  ?assertEqual(ok, pollution_gen_server:removeValue("station 2", {{Y, M, D}, H}, "PM 10")),
  ?assertEqual(ok, pollution_gen_server:removeValue({4, 4}, {{2018, 04, 12}, 12}, "temperature")).

crash_test() ->
  pollution_gen_server:crash(),
  timer:sleep(50),
  ?assert(lists:member(pollution_gen_server, registered())).
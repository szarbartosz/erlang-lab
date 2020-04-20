%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. kwi 2020 21:13
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("Lenovo").

-include_lib("eunit/include/eunit.hrl").
-compile(export_all).
-record(monitor, {stations, data}).

%% API
-export([]).

createMonitor_test() ->
  Monitor = pollution:createMonitor(),
  ?assert(is_record(Monitor, monitor)).

addStation_test() ->
  P1 = pollution:createMonitor(),
  #monitor{stations = Stations, data = Data} = pollution:addStation("station 1", {1, 1}, P1),
  ?assert(maps:is_key("station 1", Stations)),
  ?assert(lists:member({1, 1}, maps:values(Stations))),
  ?assertEqual({error, station_already_registered}, pollution:addStation("station 1", {1, 1}, #monitor{stations = Stations, data = Data})).

addValue_test() ->
  P1 = pollution:createMonitor(),
  P2 = pollution:addStation("station 1", {1, 1}, P1),
  Date = calendar:local_time(),
  P3 = pollution:addValue("station 1", Date, "PM 10", 12, P2),
  #monitor{stations = Stations, data = Data} = P3,
  ?assert(maps:is_key("station 1", Stations)),
  ?assert(lists:member({1, 1}, maps:values(Stations))),
  ?assertEqual({error, measurement_already_registered}, pollution:addValue("station 1", Date, "PM 10", 12, #monitor{stations = Stations, data = Data})),
  ?assertEqual({error, station_not_registered}, pollution:addValue({2, 2}, Date, "PM 10", 12, #monitor{stations = Stations, data = Data})).

removeValue_test() ->
  P1 = pollution:createMonitor(),
  P2 = pollution:addStation("station 1", {1, 1}, P1),
  Date = calendar:local_time(),
  {{Year, Month, Day}, {Hour, _, _}} = Date,
  ?assertEqual({error, measurement_does_not_exist}, pollution:removeValue("station 1", {{Year, Month, Day}, Hour}, "PM 10", P2)),
  P3 = pollution:addValue("station 1", Date, "PM 10", 12, P2),
  #monitor{stations = Stations, data = Data} = P3,
  ?assert(maps:is_key({{1, 1}, {{Year, Month, Day}, Hour}, "PM 10"}, Data)),
  P4 = pollution:removeValue("station 1", {{Year, Month, Day}, Hour}, "PM 10", P3),
  #monitor{stations = Stations2, data = Data2} = P4,
  ?assert(not maps:is_key({{1, 1}, {{Year, Month, Day}, Hour}, "PM 10"}, Data2)).

getOneValue_test() ->
  P1 = pollution:createMonitor(),
  P2 = pollution:addStation("station 1", {1, 1}, P1),
  Date = calendar:local_time(),
  {{Year, Month, Day}, {Hour, _, _}} = Date,
  P3 = pollution:addValue("station 1", Date, "PM 10", 12, P2),
  ?assertEqual({error, measurement_does_not_exist}, pollution:getOneValue("station 1", Date, "PM 20", P3)),
  ?assertEqual(12, pollution:getOneValue({1, 1}, {{Year, Month, Day}, Hour}, "PM 10", P3)).

getStationMean_test() ->
  P1 = pollution:createMonitor(),
  P2 = pollution:addStation("station 1", {1, 1}, P1),
  Date = calendar:local_time(),
  P3 = pollution:addValue("station 1", Date, "PM 10", 12, P2),
  P4 = pollution:addValue("station 1", {{2020, 02, 12}, {12, 54 ,12}}, "PM 10", 14, P3),
  ?assertEqual(13.0, pollution:getStationMean({1, 1}, "PM 10", P4)).

getDailyMean_test() ->
  P1 = pollution:createMonitor(),
  P2 = pollution:addStation("station 1", {1, 1}, P1),
  P3 = pollution:addStation("station 2", {2, 2}, P2),
  Date = calendar:local_time(),
  Date = calendar:local_time(),
  {{Year, Month, Day}, _} = Date,
  P4 = pollution:addValue("station 1", Date, "PM 10", 12, P3),
  P5 = pollution:addValue({2, 2}, Date, "PM 10", 14, P4),
  ?assertEqual(13.0, pollution:getDailyMean("PM 10", {Year, Month, Day}, P5)).

getMonthlyMean_test() ->
  P1 = pollution:createMonitor(),
  P2 = pollution:addStation("station 1", {1, 1}, P1),
  P3 = pollution:addStation("station 2", {2, 2}, P2),
  Date = calendar:local_time(),
  Date = calendar:local_time(),
  {{Year, Month, _}, _} = Date,
  P4 = pollution:addValue("station 1", Date, "PM 10", 12, P3),
  P5 = pollution:addValue({2, 2}, Date, "PM 10", 14, P4),
  ?assertEqual(13.0, pollution:getMonthlyMean("PM 10", {Year, Month}, P5)).

getExceededMeasurements_test() ->
  P1 = pollution:createMonitor(),
  P2 = pollution:addStation("station 1", {1, 1}, P1),
  P3 = pollution:addStation("station 2", {2, 2}, P2),
  Date = calendar:local_time(),
  Date = calendar:local_time(),
  {{Year, Month, Day}, _} = Date,
  P4 = pollution:addValue("station 1", Date, "PM 10", 12, P3),
  P5 = pollution:addValue({2, 2}, Date, "PM 10", 14, P4),
  ?assertEqual(2, pollution:getExceededMeasurements("PM 10", {Year, Month, Day}, 10, P5)),
  ?assertEqual(1, pollution:getExceededMeasurements("PM 10", {Year, Month, Day}, 13, P5)),
  ?assertEqual({error, incorrect_date}, pollution:getExceededMeasurements("PM 10", {2012, 13, 32}, 10, P5)).

test_all() ->
  createMonitor_test(),
  addStation_test(),
  addValue_test(),
  removeValue_test(),
  getOneValue_test(),
  getStationMean_test(),
  getDailyMean_test(),
  getMonthlyMean_test(),
  getExceededMeasurements_test().

%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. kwi 2020 19:34
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Lenovo").

%% API

%% server
-export([start/0, init/0, stop/0]).

%% pollution functions
-export([addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getMonthlyMean/2, getExceededMeasurements/3]).

%% monitor record
-record(monitor, {stations, data}).


start() -> register(pollutionServer, spawn(?MODULE, init, [])).

init() -> loop(pollution:createMonitor()).

stop() -> pollutionServer ! stop.


%% main server loop
loop(Monitor) ->
  receive
    {PID, {add_station, Name, {X, Y}}} ->
      UpdatedMonitor = pollution:addStation(Name, {X, Y}, Monitor),
      case is_record(UpdatedMonitor, monitor) of
        true ->
          PID ! {reply, ok},
          loop(UpdatedMonitor);
        false ->
          PID ! {reply, UpdatedMonitor},
          loop(Monitor)
      end;
    {PID, {add_value, Station, Date, Type, Value}} ->
      UpdatedMonitor = pollution:addValue(Station, Date, Type, Value, Monitor),
      case is_record(UpdatedMonitor, monitor) of
        true ->
          PID ! {reply, ok},
          loop(UpdatedMonitor);
        false ->
          PID ! {reply, UpdatedMonitor},
          loop(Monitor)
      end;
    {PID, {remove_value, Station, {{Year, Month, Day}, Hour}, Type}} ->
      UpdatedMonitor = pollution:removeValue(Station, {{Year, Month, Day}, Hour}, Type, Monitor),
      case is_record(UpdatedMonitor, monitor) of
        true ->
          PID ! {reply, ok},
          loop(UpdatedMonitor);
        false ->
          PID ! {reply, UpdatedMonitor},
          loop(Monitor)
      end;
    {PID, {get_one_value, Station, {{Year, Month, Day}, Hour}, Type}} ->
      Value = pollution:getOneValue(Station, {{Year, Month, Day}, Hour}, Type, Monitor),
      PID ! {reply, Value},
      loop(Monitor);
    {PID, {get_station_mean, Station, Type}} ->
      Mean = pollution:getStationMean(Station, Type, Monitor),
      PID ! {reply, Mean},
      loop(Monitor);
    {PID, {get_daily_mean, Type, {Year, Month, Day}}} ->
      Mean = pollution:getDailyMean(Type, {Year, Month, Day}, Monitor),
      PID ! {reply, Mean},
      loop(Monitor);
    {PID, {get_monthly_mean, Type, {Year, Month}}} ->
      Mean = pollution:getMonthlyMean(Type, {Year, Month}, Monitor),
      PID ! {reply, Mean},
      loop(Monitor);
    {PID, {get_exceeded_measurements, Type, {Year, Month, Day}, Norm}} ->
      Quantity = pollution:getExceededMeasurements(Type, {Year, Month, Day}, Norm, Monitor),
      PID ! {reply, Quantity},
      loop(Monitor);
    stop -> ok
  end.


%% client
call(Message) ->
  pollutionServer ! {self(), Message},
  receive
    {reply, Reply} -> Reply
  end.


%% function calling
addStation(Name, {X, Y}) ->
  call({add_station, Name, {X, Y}}).

addValue(Station, {{Year, Month, Day},{Hour, Minute, Second}}, Type, Value) ->
  call({add_value, Station, {{Year, Month, Day},{Hour, Minute, Second}}, Type, Value}).

removeValue(Station, {{Year, Month, Day}, Hour}, Type) ->
  call({remove_value, Station, {{Year, Month, Day}, Hour}, Type}).

getOneValue(Station, {{Year, Month, Day}, Hour}, Type) ->
  call({get_one_value, Station, {{Year, Month, Day}, Hour}, Type}).

getStationMean(Station, Type) ->
  call({get_station_mean, Station, Type}).

getDailyMean(Type, {Year, Month, Day}) ->
  call({get_daily_mean, Type, {Year, Month, Day}}).

getMonthlyMean(Type, {Year, Month}) ->
  call({get_monthly_mean, Type, {Year, Month}}).

getExceededMeasurements(Type, {Year, Month, Day}, Norm) ->
  call({get_exceeded_measurements, Type, {Year, Month, Day}, Norm}).

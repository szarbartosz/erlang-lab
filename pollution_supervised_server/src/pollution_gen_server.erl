%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. maj 2020 17:43
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-author("szarb").

-behaviour(gen_server).

%% API
-export([start_link/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getMonthlyMean/2, getExceededMeasurements/3, crash/0, stop/0, showMonitor/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-define(SERVER, ?MODULE).

-record(monitor, {stations, data}).

%% types to simplify function args
-type second_date() :: {{Year :: integer(), Month :: integer(), Day :: integer()}, {Hour :: integer(), Minute :: integer(), Second :: integer()}}.
-type hour_date() :: {{Year :: integer(), Month :: integer(), Day :: integer()}, Hour :: integer()}.
-type day_date() :: {Year :: integer(), Month :: integer(), Day :: integer()}.
-type month_date() :: {Year :: integer(), Month :: integer()}.
-type coords() :: {Lon :: float(), Lat :: float()}.

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Spawns the server and registers the local name (unique)
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, pollution:createMonitor(), []).

showMonitor() ->
  gen_server:call(?MODULE, showMonitor).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
%% @doc Initializes the server
-spec(init(Args :: #monitor{}) ->
  {ok, Monitor :: #monitor{}} | {stop, Reason :: term()} | ignore).
init(Monitor) ->
  {ok, Monitor}.

%% async requests
-spec(addStation(Name :: string(), Coords :: coords()) ->
  term()).
addStation(Name, Coords) ->
  gen_server:cast(?MODULE, {addStation, [Name, Coords]}).

-spec(addValue(Station :: term(), Date :: second_date(), Type :: string(), Value :: number()) ->
  term()).
addValue(Station, Date, Type, Value) ->
  gen_server:cast(?MODULE, {addValue, [Station, Date, Type, Value]}).

-spec(removeValue(Station :: term(), Date :: hour_date(), Type :: string()) ->
  term()).
removeValue(Station, Date, Type) ->
  gen_server:cast(?MODULE, {removeValue, [Station, Date, Type]}).

crash() -> gen_server:cast(?MODULE, crash).
stop() -> gen_server:cast(?MODULE, stop).

%% sync requests
-spec(getOneValue(Station :: term(), Date :: hour_date(), Type :: string()) ->
  term()).
getOneValue(Station, Date, Type) ->
  gen_server:call(?MODULE, {getOneValue, [Station, Date, Type]}).

-spec(getStationMean(Station :: term(), Type :: string()) ->
  term()).
getStationMean(Station, Type) ->
  gen_server:call(?MODULE, {getStationMean, [Station, Type]}).

-spec(getDailyMean(Type :: string(), Date :: day_date()) ->
  term()).
getDailyMean(Type, Date) ->
  gen_server:call(?MODULE, {getDailyMean, [Type, Date]}).

-spec(getMonthlyMean(Type :: string(), Date :: month_date()) ->
  term()).
getMonthlyMean(Type, Date) ->
  gen_server:call(?MODULE, {getMonthlyMean, [Type, Date]}).

-spec(getExceededMeasurements(Type :: string(), Date :: day_date(), Norm :: number()) ->
  term()).
getExceededMeasurements(Type, Date, Norm) ->
  gen_server:call(?MODULE, {getExceededMeasurements, [Type, Date, Norm]}).

%% @private
%% @doc Handling cast messages
handle_cast({addStation, [Name, Coords]}, Monitor) ->
  handle_cast_response(pollution:addStation(Name, Coords, Monitor), Monitor);
handle_cast({addValue, [Station, Date, Type, Value]}, Monitor) ->
  handle_cast_response(pollution:addValue(Station, Date, Type, Value, Monitor), Monitor);
handle_cast({removeValue, [Station, Date, Type]}, Monitor) ->
  handle_cast_response(pollution:removeValue(Station, Date, Type, Monitor), Monitor);
handle_cast(crash, _) ->
  2137 / 0;
handle_cast(stop, Monitor) ->
  {stop, normal, Monitor}.

handle_cast_response({error, _}, Monitor) -> {noreply, Monitor};
%%handle_cast_response({error, Message}, Monitor) -> erlang:display({error, Message}), {noreply, Monitor};
handle_cast_response(UpdatedMonitor, _) -> {noreply, UpdatedMonitor}.

%% @private
%% @doc Handling call messages
handle_call({getOneValue, [Station, Date, Type]}, _From, Monitor) ->
  {reply, pollution:getOneValue(Station, Date, Type, Monitor), Monitor};
handle_call({getStationMean, [Station, Type]}, _From, Monitor) ->
  {reply, pollution:getStationMean(Station, Type, Monitor), Monitor};
handle_call({getDailyMean, [Type, Date]}, _From, Monitor) ->
  {reply, pollution:getDailyMean(Type, Date, Monitor), Monitor};
handle_call({getMonthlyMean, [Type, Date]}, _From, Monitor) ->
  {reply, pollution:getMonthlyMean(Type, Date, Monitor), Monitor};
handle_call({getExceededMeasurements, [Type, Date, Norm]}, _From, Monitor) ->
  {reply, pollution:getExceededMeasurements(Type, Date, Norm, Monitor), Monitor};
handle_call(showMonitor, _From, Monitor) ->
  {reply, Monitor, Monitor}.

%% @private
%% @doc Handling all non call/cast messages
handle_info(_Info, Monitor) ->
  {noreply, Monitor}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
terminate(_Reason, Monitor) ->
  erlang:display(Monitor),
  ok.
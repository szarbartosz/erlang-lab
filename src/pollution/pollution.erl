%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. kwi 2020 13:25
%%%-------------------------------------------------------------------
-module(pollution).
-author("Lenovo").

%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getMonthlyMean/3, getExceededMeasurements/4]).

-record(monitor, {stations, data}).

%%createMonitor/0 - tworzy i zwraca nowy monitor zanieczyszczeń;
createMonitor() -> #monitor{stations = #{}, data = #{}}.


%%addStation/3 - dodaje do monitora wpis o nowej stacji pomiarowej (nazwa i współrzędne geograficzne), zwraca zaktualizowany monitor;
addStation(Name, {X,Y}, Monitor)
  when is_list(Name) and is_number(X) and is_number(Y) and is_record(Monitor, monitor) ->
  case maps:is_key(Name, Monitor#monitor.stations) of
    true -> io:format("Station with given name has already been registered!~n"), error;
    _ -> case lists:member({X,Y}, maps:values(Monitor#monitor.stations)) of
           true -> io:format("Station with given coordinates has already been registered!~n"), error;
           _ -> #monitor{stations = maps:put(Name, {X,Y}, Monitor#monitor.stations), data = Monitor#monitor.data}
         end
  end.


%%valueExists/2 - pomocnicza funkcja sprawdzająca, czy pomiar o danych parametrach jest już zapisany
valueExists(Tuple, Monitor) ->
  Map = maps:filter(fun (Key,_) -> Key == Tuple end, Monitor#monitor.data),
  maps:size(Map) /= 0.


%%addValue/5 - dodaje odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru, wartość), zwraca zaktualizowany monitor;
addValue(Station, {{Year, Month, Day},{Hour, _, _}}, Type, Value, Monitor)
  when is_list(Type) and is_number(Value) ->
  case maps:is_key(Station, Monitor#monitor.stations) of
    true -> case valueExists({maps:get(Station, Monitor#monitor.stations), {{Year, Month, Day}, Hour}, Type}, Monitor) of
              true -> io:format("Measurement with given parameters has already been registered!~n"), error;
              _ -> #monitor{stations = Monitor#monitor.stations, data = maps:put({maps:get(Station, Monitor#monitor.stations), {{Year, Month, Day}, Hour}, Type}, Value, Monitor#monitor.data)}
            end;
    _ -> case lists:member(Station, maps:values(Monitor#monitor.stations)) of
              true -> case valueExists({Station, {{Year, Month, Day}, Hour}, Type}, Monitor) of
                        true -> io:format("Measurement with given parameters has already been registered!~n"), error;
                        _ -> #monitor{stations = Monitor#monitor.stations, data = maps:put({Station, {{Year, Month, Day}, Hour}, Type}, Value, Monitor#monitor.data)}
                      end;
              _ -> io:format("Given Station has not been registered yet!~n"), error
         end
  end.


%%removeValue/4 - usuwa odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru), zwraca zaktualizowany monitor;
removeValue(Station, {{Year, Month, Day}, Hour}, Type, Monitor)
  when is_list(Type) ->
  case maps:is_key(Station, Monitor#monitor.stations) of
    true -> case maps:find({maps:get(Station, Monitor#monitor.stations), {{Year, Month, Day}, Hour}, Type}, Monitor#monitor.data) of
              error -> io:format("Can't delete measurement that doesnt't exist!~n"), error;
              {ok,_} -> #monitor{stations = Monitor#monitor.stations, data = maps:remove({maps:get(Station, Monitor#monitor.stations), {{Year, Month, Day}, Hour}, Type}, Monitor#monitor.data)}
            end;
    _ -> case maps:find({Station, {{Year, Month, Day}, Hour}, Type}, Monitor#monitor.data) of
           error -> io:format("Can't delete measurement that doesnt't exist!~n"), error;
           {ok,_} -> #monitor{stations = Monitor#monitor.stations, data = maps:remove({Station, {{Year, Month, Day}, Hour}, Type}, Monitor#monitor.data)}
         end
  end.



%%getOneValue/4 - zwraca wartość pomiaru o zadanym typie, z zadanej daty i stacji;
getOneValue(Station, {{Year, Month, Day}, Hour}, Type, Monitor)
  when is_list(Type) ->
  case maps:is_key(Station, Monitor#monitor.stations) of
    true -> case maps:find({maps:get(Station, Monitor#monitor.stations), {{Year, Month, Day}, Hour}, Type}, Monitor#monitor.data) of
              error -> io:format("Can't return the value of measurement that doesn't exist!~n"), error;
              {ok,_} -> maps:get({maps:get(Station, Monitor#monitor.stations), {{Year, Month, Day}, Hour}, Type}, Monitor#monitor.data)
            end;
    _ -> case maps:find({Station, {{Year, Month, Day}, Hour}, Type}, Monitor#monitor.data) of
           error -> io:format("Can't return the value of measurement that doesn't exist!~n"), error;
           {ok,_} -> maps:get({Station, {{Year, Month, Day}, Hour}, Type}, Monitor#monitor.data)
         end
  end.


%%getStationMean/3 - zwraca średnią wartość parametru danego typu z zadanej stacji;
getStationMean(Station, Type, Monitor)
  when is_list(Type) ->
  case maps:is_key(Station, Monitor#monitor.stations) of
    true -> F = fun({KeyName, _, KeyType}, _) -> (maps:get(Station, Monitor#monitor.stations) == KeyName) and (Type == KeyType) end,
            Map = maps:filter(F, (Monitor#monitor.data)),
            Sum = maps:fold(fun(_, Value, Acc) -> Acc + Value end, 0, Map),
            Sum / maps:size(Map);
    _ -> F = fun({KeyName, _, KeyType}, _) -> (Station == KeyName) and (Type == KeyType) end,
         Map = maps:filter(F, (Monitor#monitor.data)),
         Sum = maps:fold(fun(_, Value, Acc) -> Acc + Value end, 0, Map),
         Sum / maps:size(Map)
  end.


%%getDailyMean/3 - zwraca średnią wartość parametru danego typu, danego dnia na wszystkich stacjach;
getDailyMean(Type, {Year, Month, Day}, Monitor)
  when is_list(Type) ->
  case calendar:valid_date(Year, Month, Day) of
    true ->
      Map = maps:filter(fun({_, {{KeyYear, KeyMonth, KeyDay}, _}, KeyType}, _) -> ({Year, Month, Day} == {KeyYear, KeyMonth, KeyDay}) and (Type == KeyType) end, Monitor#monitor.data),
      Sum = maps:fold(fun(_, Value, Acc) -> Acc + Value end, 0, Map),
      Sum / maps:size(Map);
    false -> io:format("Given date is incorrect!~n"), error
  end.


%%getMonthlyMean/3 - zwraca średnią wartość parametru danego typu, danego miesiąca na wszystkich stacjach;
getMonthlyMean(Type, {Year, Month}, Monitor) ->
  F = fun({_, {{KeyYear, KeyMonth, _}, _}, KeyType}, _) -> ({Year, Month} == {KeyYear, KeyMonth}) and (Type == KeyType) end,
  G = fun(_, Value, Acc) -> Acc + Value end,
  Map = maps:filter(F, Monitor#monitor.data),
  Sum = maps:fold(G, 0, Map),
  Sum / maps:size(Map).


%%getExceededMeasurements/4 - zwraca ilosc pomiarow ktore w danym dniu przekroczyly norme
getExceededMeasurements(Type, {Year, Month, Day}, Norm, Monitor)
  when is_list(Type) and is_number(Norm) ->
  case calendar:valid_date(Year, Month, Day) of
    true ->
      F = fun({_, {{KeyYear, KeyMonth, KeyDay}, _}, KeyType}, Value) -> ({Year, Month, Day} == {KeyYear, KeyMonth, KeyDay}) and (Value > Norm) and (KeyType == Type) end,
      Map = maps:filter(F, (Monitor#monitor.data)),
      maps:size(Map);
    false -> io:format("Given date is incorrect!~n"), error
  end.





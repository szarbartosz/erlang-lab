%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. kwi 2020 20:32
%%%-------------------------------------------------------------------
-module(inpost).
-author("Lenovo").

%% API
-export([findMyParcelLocker/2, randomTuples/3, startParallel/2, loopParallel/3, findMyParcelLockerParallel/3, startCores/3, checkExecTime/0]).


randomTuples(N, Min, Max) -> [{rand:uniform(Max - Min + 1) + Min - 1, rand:uniform(Max - Min + 1) + Min - 1} || _ <- lists:seq(1, N)].
%%Lockers = randomTuples(1000, 0, 10000)
%%People = randomTuples(10000, 0, 10000)


%%------------------------------------------------------------------------------------------------------------------------------------

findMyParcelLocker(PersonLocation, LockerLocations)
  when is_tuple(PersonLocation) and is_list(LockerLocations) ->
  GetDistance = fun({Px, Py}, {Lx, Ly}) -> math:sqrt(math:pow((Px - Lx), 2) + math:pow((Py - Ly), 2)) end,
  DistanceList = [{{X, Y}, GetDistance(PersonLocation, {X, Y})} || {X, Y} <- LockerLocations],
  TupleSort = fun(A, B) -> element(2, A) =< element(2, B) end,
  {PersonLocation, element(1, lists:nth(1, lists:sort(TupleSort, DistanceList)))};

findMyParcelLocker(PeopleLocation, LockerLocations)
  when is_list(PeopleLocation) and is_list(LockerLocations) ->
  [findMyParcelLocker({X, Y}, LockerLocations) || {X, Y} <- PeopleLocation].

%%------------------------------------------------------------------------------------------------------------------------------------

startParallel(PeopleLocations, LockerLocations)
  when is_list(PeopleLocations) and is_list(LockerLocations) ->
  register(execTime, spawn(?MODULE, checkExecTime, [])),
  execTime ! {start, erlang:timestamp()},
  register(parallelServer, spawn(?MODULE, loopParallel, [[], 0, length(PeopleLocations)])),
  calculateLocation(parallelServer, PeopleLocations, LockerLocations).

loopParallel(List, Count, Number) ->
  receive
    stop -> List;
    {PeopleLocations, LockerLocations} ->
      case Count + 1 == Number of
        false ->loopParallel([{PeopleLocations, LockerLocations} | List], Count + 1, Number);
        true -> io:format("~w~n", [List]), execTime ! {stop, erlang:timestamp()}
      end;
    _ -> io:format("syntax error!~n")
  after
    10000 -> io:format("timout!~n")
  end.

calculateLocation(_, [], _) -> ok;
calculateLocation(parallelServer, [Location | PeopleLocations], LockerLocations) ->
  spawn(fun() -> findMyParcelLockerParallel(parallelServer, Location, LockerLocations) end),
  calculateLocation(parallelServer, PeopleLocations, LockerLocations).

findMyParcelLockerParallel(parallelServer, PersonLocation, LockerLocations)
  when is_tuple(PersonLocation) and is_list(LockerLocations) ->
  {_, LockerLocation} = findMyParcelLocker(PersonLocation, LockerLocations),
  parallelServer ! {PersonLocation, LockerLocation}.

checkExecTime() ->
  receive
    {start, T} -> Start = T, checkExecTime(Start)
  end.
checkExecTime(Start) ->
  receive
    {stop, T} -> io:format("Execution time: ~w microsec~n", [timer:now_diff(T, Start)])
  end.

%%------------------------------------------------------------------------------------------------------------------------------------

indexTheList([], _, Result) -> Result;
indexTheList([H | T], Acc, Result) ->
  indexTheList(T, Acc + 1, [{H, Acc} | Result]).

startCores(PeopleLocations, LockerLocations, CoresNumber)
when is_list(PeopleLocations) and is_list(LockerLocations) ->
  register(coreServer, spawn(?MODULE, loopParallel, [[], 0, length(PeopleLocations)])),
  register(execTime, spawn(?MODULE, checkExecTime, [])),
  execTime ! {start, erlang:timestamp()},
  IndexedPeopleLocations = indexTheList(PeopleLocations, 0, []),
  calculateLocationCore(coreServer, IndexedPeopleLocations, LockerLocations, 0, CoresNumber).

calculateLocationCore(coreServer, IndexedPeopleLocations, LockerLocations, Number, CoresNumber)
  when Number < CoresNumber ->
  PeopleLocations = [X || {X, Y} <- IndexedPeopleLocations, Y rem CoresNumber == Number],
  spawn(fun() -> findMyParcelLockerCore(coreServer, PeopleLocations, LockerLocations) end),
  calculateLocationCore(coreServer, IndexedPeopleLocations, LockerLocations, Number + 1, CoresNumber);
calculateLocationCore(_, _, _, _, _) -> ok.

findMyParcelLockerCore(_, [], _) -> ok;
findMyParcelLockerCore(coreServer, [Location | PeopleLocations], LockerLocations)
  when is_tuple(Location) and is_list(LockerLocations) ->
  {_, LockerLocation} = findMyParcelLocker(Location, LockerLocations),
  coreServer ! {Location, LockerLocation},
  findMyParcelLockerCore(coreServer, PeopleLocations, LockerLocations).
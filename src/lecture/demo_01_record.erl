%%%-------------------------------------------------------------------
%%% @author Lenovo
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. kwi 2020 10:41
%%%-------------------------------------------------------------------
-module(demo_01_record).
-author("Lenovo").

%% API
-export([testRecord/0]).
-record(grupa, {nazwa, licznosc, stan=aktywna}).


testRecord() ->
  Grupa1 = #grupa{nazwa="Grupa 1", licznosc=12},
  Grupa2 = #grupa{nazwa="Grupa 2", licznosc=7, stan=0},

  io:format(Grupa2#grupa.nazwa).

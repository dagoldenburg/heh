%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Feb 2018 8:50 PM
%%%-------------------------------------------------------------------
-module(wtftest).
-behaviour(gen_statem).
-author("Dag").

%% API
-export([start_link/0, init/1, callback_mode/0, select/3, tea/0, espresso/0, americano/0, cappuccino/0, pay/1, cup_removed/0, cancel/0, payment/3, remove/3]).

start_link() ->
  gen_statem:start_link({local,?MODULE},?MODULE,[],[]).

init([]) ->
  io:format("Make Your Selection", []),
  {ok, select, null}.

callback_mode() -> state_functions.

%% State: drink selection
select(cast, {selection,Type,Price}, LoopData) ->
  io:format("Please pay:~p~n",[Price]),
  {next_state, payment, {Type, Price, 0}};
select(cast, {pay, Coin}, LoopData) ->
  io:format(hw:return_change(Coin)),
  {keep_state, LoopData};
select(cast,_Other, LoopData) ->
  {keep_state, LoopData}.

%% Client Functions for Drink Selections
tea() ->
  gen_statem:cast(?MODULE, {selection,tea,100}).
espresso() ->
  gen_statem:cast(?MODULE, {selection,espresso,150}).
americano() ->
  gen_statem:cast(?MODULE, {selection,americano,100}).
cappuccino() ->
  gen_statem:cast(?MODULE, {selection,cappuccino,150}).

%% Client Functions for Actions
pay(Coin) -> gen_statem:cast(?MODULE, {pay, Coin}).
cancel() -> gen_statem:cast(?MODULE, cancel).
cup_removed() -> gen_statem:cast(?MODULE, cup_removed).



payment(cast, {pay, Coin}, {Type,Price,Paid})
  when Coin+Paid >= Price ->
  NewPaid = Coin + Paid,
  io:format(NewPaid - Price),
  io:format("Preparing Drink.",[]),
  io:format(hw:drop_cup(), hw:prepare(Type)),
  io:format("Remove Drink.", []),
  {next_state, remove, null};
payment(cast, {pay, Coin}, {Type,Price,Paid})
  when Coin+Paid < Price ->
  NewPaid = Coin + Paid,
  hw:display("Please pay:~w",[Price - NewPaid]),
  {keep_state, {Type, Price, NewPaid}};

payment(cast, cancel, {Type, Price, Paid}) ->
  hw:return_change(Paid),
  hw:display("Make Your Selection", []),
  {next_state, select, null};
payment(cast, _Other, LoopData) ->
  {keep_state, LoopData}.

%% State: remove cup
remove(cast, cup_removed, LoopData) ->
  hw:display("Make Your Selection", []),
  {next_state, select, LoopData};
remove(cast, {pay, Coin}, LoopData) ->
hw:return_change(Coin),
{keep_state, LoopData};
remove(cast, _Other, LoopData) ->
{keep_state, LoopData}.


%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2018 12:03 PM
%%%-------------------------------------------------------------------
-module(db_save).
-behaviour(gen_server).

-author("Dag").

%% API

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3, stop/0, update_db/1, retrieve_from_db/1, new/0, write/3, read/2, match/2, delete/2]).

%%%-------------------------------------------------------------------
%%% Client functions
%%%-------------------------------------------------------------------


start_link()->
  gen_server:start_link({global,?MODULE}, ?MODULE, [],[]).

stop()->
  gen_server:cast({global,?MODULE}, stop).

update_db(Data)->gen_server:cast({global,?MODULE},Data).

retrieve_from_db(Condition)->gen_server:call({global,?MODULE},Condition).


%%%-------------------------------------------------------------------
%%% Call back functions
%%%-------------------------------------------------------------------

init(_Args)->
  process_flag(trap_exit, true),
  {ok,new()}.

handle_call({read,Key}, _From, State) ->
  {reply,read(Key,State),State};

handle_call({match,Element}, _From, State) ->
  {reply,match(Element,State),State}.

handle_cast({write,Key,Element}, State) ->
  {noreply,write(Key,Element,State)};

handle_cast({delete,Key}, State) ->
  {noreply,delete(Key,State)};

handle_cast(stop, State) ->
  {noreply,terminate(normal_exit,State)}.

handle_info(_Info, _State) ->
  io:format("info~n").

terminate(Reason, State) ->
  io:format("Server was terminated with reason ~p and the State was ~p",[Reason,State]).

code_change(_OldVsn, _State, _Extra) ->
  erlang:error(not_implemented).

%%%-------------------------------------------------------------------
%%% Back end logic
%%%-------------------------------------------------------------------

%Creates empty db
new()->[].

%Writes key and element to database
write(Key,Element,[])-> [{Key,Element}];
write(Key,Element,[{Key,_}|Db])-> [{Key,Element}|Db];
write(Key,Element,[Current | Db])-> [Current | write(Key,Element,Db)].

%Gets element for matching key
read(Key,[{Key,Element} | _Db])-> {ok,Element};
read(Key,[_Tuple|Db]) -> read(Key,Db);
read(_,[]) -> {error,instance}.

%Gets all matching elements
match(Element,[{Key,Element}|Db])-> [Key|match(Element,Db)];
match(Element,[ _ |Db])->match(Element,Db);
match(_Element,[])->[].

%Deletes and element with matching key
delete(Key,[{Key,_}|Db])-> Db;
delete(Key,[Tuple|Db])-> [Tuple|delete(Key,Db)];
delete(_,[])->[].
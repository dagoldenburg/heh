

%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2018 12:03 PM
%%%-------------------------------------------------------------------
-module(db).
-behaviour(gen_server).

-author("Dag").

%% API

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3
  , update_db/1, retrieve_from_db/1, new/0, write/3, read/2, match/2, delete/2]).

%%%-------------------------------------------------------------------
%%% Client functions
%%%-------------------------------------------------------------------

%start and link server
start_link()->
  gen_server:start_link({global,?MODULE}, ?MODULE, [],[]).

%updates db with some data(write, delete)
update_db(Data)->gen_server:cast({global,?MODULE},Data).

%retreives data(read, match)
retrieve_from_db(Condition)->gen_server:call({global,?MODULE},Condition).

%%%-------------------------------------------------------------------
%%% Call back functions
%%%-------------------------------------------------------------------
%init callback
init(_Args)->
  io:format("Server starting~n"),
  %process_flag(trap_exit, true),
  {ok,new()}.
handle_info(_Info, _State) ->
  io:format("info~n").

terminate(Reason, State) ->
  io:format("Server was terminated with reason ~p and the State was ~p",[Reason,State]),
  ok.

code_change(_OldVsn, _State, _Extra) ->
  erlang:error(not_implemented).

%%% UNLOCKED----------------------------------------------------------

%handle read
handle_call({read,Key}, _From, State) ->
  {reply,read(Key,State),State};

%handle match
handle_call({match,Element}, _From, State) ->
  {reply,match(Element,State),State}.

%handle write
handle_cast({write,Key,Element}, State) ->
  {noreply,write(Key,Element,State)};

%handle delete
handle_cast({delete,Key}, State) ->
  {noreply,delete(Key,State)};
%handle stop
handle_cast(stop, State) ->
  terminate(normal_exit,State).

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
%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Feb 2018 6:31 PM
%%%-------------------------------------------------------------------
-module(dblogic).
-behaviour(gen_statem).
-author("Dag").

%% API
-export([callback_mode/0, start_link/0, init/1, new/0, write/3, read/2, match/2, delete/2, locked/3, unlocked/3, unlock/1, querry_db/1, lock/2]).
%%%-------------------------------------------------------------------
%%% Client functions
%%%-------------------------------------------------------------------


start_link()->
  gen_statem:start_link({local,?MODULE}, ?MODULE,[],[]).

lock(Lock_holder,From)->
  gen_statem:call(?MODULE,{lock,Lock_holder,From}).

unlock(Lock_holder)->
  gen_statem:call(?MODULE,{unlock,Lock_holder}).

querry_db(Tuple)->
  gen_statem:call(?MODULE,Tuple).


%%%-------------------------------------------------------------------
%%% Call back functions
%%%-------------------------------------------------------------------

init([])->
  io:format("bajset~n"),
  {ok,unlocked,new()}.

callback_mode() ->
  state_functions.



locked(cast,{unlock,Lock_holder},{Db,Lock_holder})->
  io:format("unlocked~n"),
  {next_state,unlocked,Db};

locked(cast,{write,Key,Element,Lock_holder},{Db,Lock_holder})->
  io:format("write~n"),
  {keep_state,{write(Key,Element,Db),Lock_holder}};

locked(cast,{delete,Key,Lock_holder},{Db,Lock_holder})->
  io:format("delete~n"),
  {keep_state,{delete(Key,Db),Lock_holder}};

locked({call,From},{match,Element,Lock_holder},{Db,Lock_holder})->
  io:format("delete~n"),
  {keep_state,Db,[{reply,From,match(Element,Db)}]};

locked({call,From},{read,Key,Lock_holder},{Db,Lock_holder})->
  io:format("read~n"),
  {keep_state,{Db,Lock_holder},[{reply,From,read(Key,Db)}]}.




unlocked(cast,{lock, Lock_holder},Db)->
  io:format("locked~n"),
  {next_state,locked,{Db,Lock_holder}};

unlocked(cast,{write,Key,Element,_},Db)->
  io:format("write~n"),
  {keep_state,write(Key,Element,Db)};

unlocked(cast,{delete,Key,_},Db)->
  io:format("delete~n"),
  {keep_state,delete(Key,Db)};

unlocked(call,{match,Element,_},Db)->
  io:format("delete~n"),
  {keep_state,Db,[{match(Element,Db)}]};

unlocked({call,From},{read,Key,_},Db)->
  io:format("read~n"),
  {keep_state,Db,[{reply,From,read(Key,Db)}]}.

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
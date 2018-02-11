%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Feb 2018 8:34 PM
%%%-------------------------------------------------------------------
-module(my_db).
-author("Dag").

%% API
-export([start/0, stop/0, write/2, delete/1, read/1, match/1, unlock/0, lock/0, crash/0, test_if_backend_locked/0, test/0]).

%starts new db process and creates a new db
start()->
  register(dbconnection, spawn(db,backend_loop,[])),
  dbconnection ! new,
  ok.
%stop db process
stop()->
  dbconnection ! stop,
  ok.
%writes to db
write(Key,Element)->
  dbconnection ! {write, Key, Element,self()},
  receive
    {write,Answer}->
      Answer
  end.
%deletes an element based on key
delete(Key)->
  dbconnection ! {delete, Key,self()},
  ok.
%gets matching element for a key
read(Key)->
  dbconnection ! {read,Key,self()},
  receive
    {read,Answer}->
      Answer
  end.
%gets matching keys for an element
match(Element)->
  dbconnection ! {match,Element,self()},
  receive
    {match,Answer}->
      Answer
  end.
%locks the db
lock()->
  dbconnection ! {lock,self()},
  receive
  locked->
    ok
  end.
%unlocks the db
unlock()->
  dbconnection ! {unlock,self()},
  ok.
%makes the process crash in a bad way
crash()->
  exit(non_normal_exit).


%%% testing concurrent locking
test_if_backend_locked()->
  spawn(my_db,test,[]).

test()->
  lock().



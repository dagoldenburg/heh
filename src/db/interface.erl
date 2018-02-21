%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Feb 2018 8:34 PM
%%%-------------------------------------------------------------------
-module(interface).
-author("Dag").

%% API
-export([write/2, delete/1, read/1, match/1, start/0, unlock/0, lock/0, test/2, test_if_backend_locked/2, tl1/0, tl/0, stop/0]).

%%starts new db process and creates a new db
start()->
  db_old:start_link(),
  ok.

stop()->
  db_old:stop(),
  ok.

%writes to db
write(Key,Element)->
  db_old:update_db({write,Key,Element,self()}),
  ok.

%deletes an element based on key
delete(Key)->
  db_old:update_db({delete,Key,self()}),
  ok.

%gets matching element for a key
read(Key)->
  db_old:retrieve_from_db({read,Key,self()}).

%gets matching keys for an element
match(Element)->
  db_old:retrieve_from_db({match,Element,self()}).

%locks the db
lock()->
  db_old:lock(self()),
ok.

%unlocks the db
unlock()->
  db_old:unlock(self()),
ok.


%%% testing concurrent locking
tl1()->
  spawn(interface,tl,[]).
%catch is for timeout exception
tl()->
  db_old:lock(self()).
%%% test writing while locked
test_if_backend_locked(Key,Element)->
  spawn(interface,test,[Key,Element]).

test(Key,Element)->
  db_old:update_db({write,Key,Element,self()}).





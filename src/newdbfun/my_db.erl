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
-export([write/2, delete/1, read/1, match/1, stop/0]).

stop()->
  db:update_db(stop),
  ok.

%writes to db
write(Key,Element)->
  db:update_db({write,Key,Element}),
  ok.

%deletes an element based on key
delete(Key)->
  db:update_db({delete,Key}),
  ok.

%gets matching element for a key
read(Key)->
  db:retrieve_from_db({read,Key}).

%gets matching keys for an element
match(Element)->
  db:retrieve_from_db({match,Element}).



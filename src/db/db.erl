

%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2018 12:03 PM
%%%-------------------------------------------------------------------
-module(db).
-author("Dag").

%% API

-export([destroy/1, write/3, read/2, match/2, delete/2, new/0,  backend_loop/0]).

%Creates empty db
new()->[].
%Destroys db
destroy(_Db) -> ok.

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


%Initiates the backend loop

backend_loop()->
  process_flag(trap_exit, true),
  backend_loop(new()).
%Unlocked backend
backend_loop(Mynicelist)->
  receive
  %Makes clean database
    new->
      new(),
      backend_loop(Mynicelist);
  %Writes to db and returns ok when complete
    {write, Key,Element,Pid}->
      Pid ! {write,ok},
      backend_loop(write(Key,Element,Mynicelist));

  %Gets the matching element for a key and returns them to caller
    {read, Key,Pid}->
      Pid ! {read,read(Key,Mynicelist)},
      backend_loop(Mynicelist);

  %Gets all matching keys for an element and returns them to caller
    {match, Element,Pid}->
      Pid ! match(Element,Mynicelist),
      backend_loop(Mynicelist);

  %Deletes an element
    {delete, Key}->
      backend_loop(delete(Key,Mynicelist));
    stop -> true;
    %Links and locks the backend
    {lock,Pid} ->
      link(Pid),
      Pid ! locked,
      backend_loop(Mynicelist,Pid)

  end.
%Locked backend
backend_loop(Mynicelist,Pid)->
  receive
    %Makes clean database
    new->
      new(),
      backend_loop(Mynicelist,Pid);
    %Writes to db and returns ok when complete
    {write, Key,Element,Pid}->
      Pid ! {write,ok},
      backend_loop(write(Key,Element,Mynicelist),Pid);
    %Gets the matching element for a key and returns them to caller
    {read, Key,Pid}->
      Pid ! {read,read(Key,Mynicelist)},
      backend_loop(Mynicelist,Pid);
    %Gets all matching keys for an element and returns them to caller
    {match, Element,Pid}->
      Pid ! match(Element,Mynicelist),
      backend_loop(Mynicelist,Pid);
    %Deletes an element
    {delete, Key,Pid}->
      backend_loop(delete(Key,Mynicelist),Pid);

    stop -> true;
    %Unlinks and returns to unlocked state
    {unlock,Pid} ->
      unlink(Pid),
      backend_loop(Mynicelist);

    %Clean up from normal exit from messagequeue that unlink is responsible for
    {'EXIT', Pid, normal} ->
      backend_loop(Mynicelist,Pid);
    %Traps exit and returns to unlocked state
    {'EXIT', Pid, Reason} ->
      io:format("Got exit signal: ~p~n", [Reason]),
      backend_loop(Mynicelist)
  end.
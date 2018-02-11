%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Feb 2018 5:34 PM
%%%-------------------------------------------------------------------
-module(mutex).
-author("Dag").

%% API
-export([start_processes/0, requester1/1, requester2/1, mutexlock/1, mutexlock_init/0]).

start_processes()->
  Pid = spawn(mutex,mutexlock_init,[]),
  spawn(mutex,requester1,[Pid]),
  spawn(mutex,requester2,[Pid]).

requester1(Pid)->
  process_flag(trap_exit, true),
  io:format("1sending wait ~p~n",[self()]),
  Pid ! {wait,self()},
  timer:sleep(3000),
  exit(non_normal_exit),
  io:format("1sending free ~p~n",[self()]),
  Pid ! {free,self()}.
requester2(Pid)->
  timer:sleep(1000),
  io:format("2sending wait ~p~n",[self()]),
  Pid ! {wait,self()},
  timer:sleep(4000),
  io:format("2sending wait ~p again~n",[self()]),
  Pid ! {free,self()},
  io:format("2sending free ~p~n",[self()]).

mutexlock_init()->
  process_flag(trap_exit, true),
  mutexlock(0).

mutexlock(0)->
  io:format("unlock~n"),
receive
  {wait,Pid}-> io:format("Xwait pid ~p~n",[Pid]), mutexlock(Pid)
end;
mutexlock(Pid)->
  io:format("linked~n"),
  link(Pid),
  receive
    {free,Pid}->
      io:format("Xfree pid ~p~n",[Pid]),
      unlink(Pid),
      mutexlock(0);

    {'EXIT', Pid, _Reason} ->
      io:format("Got exit signal: ~p , unlocking~n", [_Reason]),
      io:format("unlinked~n"),
      unlink(Pid),
      mutexlock(0)
  end.

%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Feb 2018 7:19 PM
%%%-------------------------------------------------------------------
-module(ringmy).
-author("Dag").

%% API
-export([start/3]).

%% @doc Starts the master process which in turn spawns off the
%% individual processes which will receive a message.
-spec start(non_neg_integer(), non_neg_integer(), term()) -> pid().
start(ProcNum, MsgNum, Message)->
  spawn(ring, master, [ProcNum, MsgNum, Message]).

%% Will start ProcNum slave processes
-spec start_slaves(non_neg_integer(), pid()) -> pid().
start_slaves(NrOfProc,Pid)->
  NewPid=spawn(ring,loop,[NrOfProc,Pid]),
  start_slaves(NrOfProc-1,NewPid).

%% @private This function starts the slave pids and then gets into
%% the loop which will send the Message MsgNum times to
%% the slaves.
-spec master(non_neg_integer(), non_neg_integer(), term()) -> stop | no_return().
master(ProcNum, MsgNum, Message)->
  Pid = start_slaves(ProcNum,self()),
  master_loop(MsgNum, Message, Pid).

%% The master loop will loop MsgNum times sending a message to
%% Pid. It will iterate every time it receives the Message it is
%% sent to the next process in the ring.
-spec master_loop(non_neg_integer(), term(), pid()) -> stop | no_return().
master_loop(0, _Message, Pid)->
  io:format("Process:1 terminating~n"),
  Pid ! stop;
master_loop(MsgNum, Message, Pid)->
  Pid ! Message,
  receive
    Message->
      master_loop(MsgNum-1,Message,Pid)
  end.

%% @private This is the slave loop, where upon receiving a message, the
%% process forwards it to the next process in the ring. Upon
%% receiving stop, it sends the stop message on and terminates.
-spec loop(non_neg_integer(), pid()) -> stop | no_return().
loop(ProcNum, Pid)->
  receive
    stop ->
      io:format("Process:~p terminating~n",[ProcNum]),
      Pid ! stop;
    Message ->
      io:format("Process:~p received: ~p~n", [ProcNum, Message]),
      Pid!Message,
      loop(ProcNum, Pid)
  end.
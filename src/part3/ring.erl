%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File: ring.erl
%% @author trainers@erlang-solutions.com
%% @copyright 1999-2011 Erlang Solutions Ltd.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(ring).
% Client Functions
-export([start/3]).

%% Internal Exports
-export([master/3, loop/2]).

%% @doc Starts the master process which in turn spawns off the
%% individual processes which will receive a message.
-spec start(non_neg_integer(), non_neg_integer(), term()) -> pid().
start(ProcNum, MsgNum, Message)->
  spawn(ring, master, [ProcNum, MsgNum, Message]).

%% @private This function starts the slave pids and then gets into
%% the loop which will send the Message MsgNum times to
%% the slaves.
-spec master(non_neg_integer(), non_neg_integer(), term()) -> stop | no_return.

master(ProcNum, MsgNum, Message)->
  Pid = start_slaves(ProcNum,self()),
  master_loop(MsgNum, Message, Pid).


%% Will start ProcNum slave processes
-spec start_slaves(non_neg_integer(), pid()) -> pid().
start_slaves(1, Pid)->
  Pid;
start_slaves(ProcNum, Pid)->
  NewPid = spawn(ring, loop, [ProcNum, Pid]),
  start_slaves(ProcNum - 1, NewPid).

%% The master loop will loop MsgNum times sending a message to
%% Pid. It will iterate every time it receives the Message it is
%% sent to the next process in the ring.
-spec master_loop(non_neg_integer(), term(), pid()) -> stop | no_return().
master_loop(0, _Message, Pid)->
  io:format("Process:1 terminating~n"),
  Pid ! stop;
master_loop(MsgNum, Message, Pid) ->
  Pid ! Message,
  receive
  Message ->
  io:format("Process:1 received:~p~n",[Message]),
  master_loop(MsgNum - 1, Message, Pid)
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
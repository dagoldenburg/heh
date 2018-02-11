%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2018 7:53 PM
%%%-------------------------------------------------------------------
-module(echoserv).
-author("Dag").

%% API
-export([print/1, stop/0, start/0, listen/0]).

start()-> register(echo, spawn(echoserv,listen,[])).

stop()-> echo ! stop.

print(Term) -> echo ! {print, Term}.

listen()->
  receive
      {print, Msg}->
        io:format("~p~n",[Msg]),
        listen();
    stop -> true
  end.
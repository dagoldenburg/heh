%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Feb 2018 7:12 PM
%%%-------------------------------------------------------------------
-module(dbsup).
-author("Dag").

-behaviour(supervisor).



-export([init/1, start_link/0, stop/0, start_link_shell/0]).
%%%%%%%%%%%%%%%%%%%%%
%Client function
%%%%%%%%%%%%%%%%%%%%%%

start_link_shell()->
  {ok,Pid} = supervisor:start_link({global,?MODULE},?MODULE,self()),
  unlink(Pid).

start_link()->
  supervisor:start_link({global,?MODULE},?MODULE,self()).
stop() ->
   exit(whereis(db), shutdown).
%%%%%%%%%%%%%%%%%%%%%
%Call back function
%%%%%%%%%%%%%%%%%%%%%%
init(_Args) ->
  io:format("supervisor starting~n"),

  RestartStrategy = one_for_one,
  MaxRestarts = 5,
  MaxSecondsBetweenRestarts = 5,
  Flags = {RestartStrategy,MaxRestarts,MaxSecondsBetweenRestarts},

  Restart = permanent,
  Shutdown = 2000,
  Type = worker,
  ChildSpecifications = {db,{db,start_link,[]},Restart,Shutdown,Type,[db]},
  {ok,{Flags,[ChildSpecifications]}}.
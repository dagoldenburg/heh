%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2018 11:52 AM
%%%-------------------------------------------------------------------
-module(boolean).
-author("Dag").

%% API
-export([b_not/1,b_and/2,b_or/2]).


b_not(false) -> true;
b_not(true) -> false.

b_and(true,true) -> true;
b_and(true,false) -> false;
b_and(false,true) -> false;
b_and(false,false) -> false.


b_or(true,true) -> true;
b_or(true,false) -> true;
b_or(false,true) -> true;
b_or(false,false) -> false.




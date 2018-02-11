%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2018 1:50 PM
%%%-------------------------------------------------------------------
-module(ml).
-author("Dag").

%% API
-export([filter/2, reverse/2, reverse/1, concatenate/1, flatten/1, concatenate1/2]).


filter([H|T],Threshold) when H =< Threshold -> [H|filter(T,Threshold)];
filter([H|_],Threshold) when H > Threshold -> [];
filter([],_)-> [].

reverse(List)->reverse(List,[]).
reverse([H|T],Buffer)->reverse(T,[H|Buffer]);
reverse(_,Buffer)->Buffer.

concatenate([])->[];
concatenate([H|T])->concatenate1(H,T).

concatenate1([H|T],List)->[H|concatenate1(T,List)];
concatenate1([],List)->concatenate(List).

flatten([H|T]) when is_list(H)->concatenate([flatten(H),flatten(T)]);
flatten([H|T])-> [H|flatten(T)];
flatten([])->[].
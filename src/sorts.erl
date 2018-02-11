%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2018 4:15 PM
%%%-------------------------------------------------------------------
-module(sorts).
-author("Dag").

%% API
-export([quicksort/1, mergesort/1]).

quicksort([])->[];
quicksort([Pivot|Rest])->
  {Lower,Higher} = partition(Pivot,Rest),
  quicksort(Lower) ++ [Pivot] ++ quicksort(Higher).

partition(Pivot,Rest)->partition(Pivot,Rest,{[],[]}).

partition(_Pivot,[],ResultTuple)-> ResultTuple;
partition(Pivot,[Value|Rest],{L,H}) when Value=< Pivot -> partition(Pivot,Rest,{[Value|L],H});
partition(Pivot,[Value|Rest],{L,H}) -> partition(Pivot,Rest,{L,[Value|H]}).

mergesort([])->[];
mergesort([X])->[X];
mergesort(List) when is_list(List) -> {Left,Right} = split(length(List) div 2,List),
            merge(mergesort(Left),mergesort(Right)).

split(Length,List) -> split(Length,List,[]).
split(0,List,Acc)->{Acc,List};
split(N,[H|T],Acc)-> split(N-1,T,[H|Acc]).

merge([], Right) -> Right;
merge(Left, []) -> Left;
merge(Left = [L|Ls],Right = [R|Rs])->
  if
      L=<R -> [L|merge(Right,Ls)];
      L>R -> [R|merge(Left,Rs)]
  end.

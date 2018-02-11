%%%-------------------------------------------------------------------
%%% @author Dag
%%% @copyright (C) 2018, <KTH>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2018 5:47 PM
%%%
%%% Info: Database based on a binary tree structure.
%%%-------------------------------------------------------------------
-module(dbtree).
-author("Dag").

%% API.
-export([new/0, write/3, read/2, match/2, destroy/1, delete/2, swap_nodes/2]).


%Create new database.
new()->empty.

%Delete database.
destroy(_Tuple)-> deleted.

%Write in first element.
write(Key,Element,empty)->{Key,Element,empty,empty};
%Write to left leaf.
write(Key,Element,{_Key,_Element,empty,_Right}) when Key =< _Key-> {_Key,_Element,{Key,Element,empty,empty},_Right};
%Write to right left.
write(Key,Element,{_Key,_Element,_Left,empty}) when Key > _Key-> {_Key,_Element,_Left,{Key,Element,empty,empty}};
%if it is leaf
write(Key,Element,{_Key,_Element,empty,empty})->
  if
    Key =< _Key-> {_Key,_Element,{Key,Element,empty,empty},empty};
    Key > _Key-> {_Key,_Element,empty,{Key,Element,empty,empty}}
  end;
%Recursive part of the function, goes to the left if key value is lower or equal, right if higher.
write(Key,Element,{_Key,_Element,_Left,_Right}) ->
if
  Key =< _Key-> {_Key,_Element,write(Key,Element,_Left),_Right};
  Key > _Key-> {_Key,_Element,_Left,write(Key,Element,_Right)}
end.

%If no matching key is found, just return empty for an already empty node(leaf).
read(_Key,empty)-> empty;
%Returns element for matching keys.
read(Key,{Key,_Element,_Left,_Right})-> _Element;
%Recursive part, lower or equal key value goes left, higher goes right.
read(Key,{_Key,_Element,_Left,_Right}) ->
  if Key =< _Key -> read(Key,_Left);
     Key > _Key -> read(Key,_Right)
  end.

%If no matching element is found, just return empty for an already empty node(leaf).
match(_Element,empty)-> empty;
%Returns key for matching elements.
match(Element,{_Key,Element,_Left,_Right})-> _Key;
%Recursive part, goes left if lower or equal element value, right if higher.
match(Element,{_Key,_Element,_Left,_Right}) ->
  if Element =< _Element ->match(Element,_Left);
      Element > _Element ->match(Element,_Right)
  end.

%If no matching key is found, just return empty for an already empty node(leaf).
delete(_Key,empty)->empty;
%If it is a leaf node, just remove it
delete(Key,{Key,_Element,empty,empty})-> empty;
%If it isnt a leaf node but only has a child node on the left side, move the childnode up
delete(Key,{Key,_Element,_Left,empty})-> _Left;
%If it isnt a leaf node but only has a child node on the right side, move the childnode up
delete(Key,{Key,_Element,empty,_Right})-> _Right;
%If keys match but the node has children, swap the nodes
delete(Key,{Key,_Element,_Left,_Right})->swap_nodes(_Left,_Right);
%Recursive part,goes left for lower or equal value of key, right for higher.
delete(Key,{_Key,_Element,_Left,_Right})->
  if Key =< _Key -> {_Key,_Element,delete(Key,_Left),_Right};
     Key > _Key -> {_Key,_Element,_Left,delete(Key,_Right)}
  end.

%Helper function for delete to swap out the owner of nodes when a node with children gets deleted.
swap_nodes(_PrevOwnerLeft,{Key,Element,_Left,empty})->{Key,Element,_PrevOwnerLeft,_Left};
swap_nodes(_PrevOwnerLeft,{Key,Element,_Left,_Right})->{Key,Element,_PrevOwnerLeft,swap_nodes(_Left,_Right)}.
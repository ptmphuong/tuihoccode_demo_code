% general approach:
% if the upper square is blue => flip the current square
% if the uppoer square is red => no nothing

% steps:
% generate all possibilities of the first row
% generate the starting grid, flat, all blues
% iterate from the second row til the end of the grid. For each square:
% calculate its row, col based on its index => upper square row = cur row - 1.
% calculate the upper square index based on the row, col values
% check upper square colors and follow the general approach.
% when iteration is done, check if all squares are red.

oppositeColor(red, blue).
oppositeColor(blue, red).


solve_opt(N, FinalGrid, FirstRow) :-
    TotalLength is N * N,
    generate_grid_flat(TotalLength, Grid),
    generate_first_row(N, FirstRow),
    flip_first_row(N, 0, FirstRow, Grid, FirstRowFlippedGrid),
    explore(N, TotalLength, N, FirstRowFlippedGrid, FinalGrid).


allRed([]).
allRed([red|Tail]) :-
    allRed(Tail).


% Generate the original state of the grid. Flattened to a 1d list.
generate_grid_flat(0, []).    
generate_grid_flat(Length, [blue|Grid]) :-
    Length > 0,
    NextLength is Length - 1,
    generate_grid_flat(NextLength, Grid).


% All possible of first row: length of N, made up of 0s and 1s.
% 0: no flip. 1: flip.
generate_first_row(0, []).
generate_first_row(Length, [Head|Tail]) :-
    Length > 0,
    (Head is 0; Head is 1),
    NewLength is Length - 1,
    generate_first_row(NewLength, Tail).


% Flip first row.
% Reach base case when Index = N.
flip_first_row(N, N, _FirstRow, CurState, CurState).
% If Action is 0, no flip. Move to the next index.
flip_first_row(N, Index, [Action|FirstRowRest], CurState, FinalFlippedState) :-
	Action is 0,
    NextIndex is Index + 1,
    flip_first_row(N, NextIndex, FirstRowRest, CurState, FinalFlippedState).
% If Action is 1, flip. Then move to the next index.
flip_first_row(N, Index, [Action|FirstRowRest], CurState, FinalFlippedState) :-
    Action is 1,
    flip(N, Index, CurState, FlippedState),
    NextIndex is Index + 1,
    flip_first_row(N, NextIndex, FirstRowRest, FlippedState, FinalFlippedState).

   
% explore(N, N*N, CurInd, CurStates, FinalGrid)
% finished exploring all squares
explore(_N, Total, Total, CurStates, FinalGrid) :-
    append(CurStates, [], FinalGrid),
    allRed(CurStates).

% upper square is red. do nothing, move to the next index.
explore(N, Total, CurInd, CurStates, FinalGrid) :-
    CurInd < Total,
	upper_square_is_red(N, CurInd, CurStates),
    NextInd is CurInd + 1,
    explore(N, Total, NextInd, CurStates, FinalGrid).

% upper square is red. flip this square, move to the next index.
explore(N, Total, CurInd, CurStates, FinalGrid) :-
    CurInd < Total,
    \+upper_square_is_red(N, CurInd, CurStates),
    flip(N, CurInd, CurStates, FlippedStates),
    NextInd is CurInd + 1,
    explore(N, Total, NextInd, FlippedStates, FinalGrid).


upper_square_is_red(N, CurInd, CurStates) :-
    get_pos(N, CurInd, CurRow, CurCol),
    PrevRow is CurRow - 1,
    get_index(N, PrevRow, CurCol, UpperSquareInd),
    isRed(UpperSquareInd, CurStates).


flip(N, CurInd, CurStates, FlippedAllSquares) :-
    get_pos(N, CurInd, CurRow, CurCol),
    PrevRow is CurRow - 1,
    PrevCol is CurCol - 1,
    NextRow is CurRow + 1,
    NextCol is CurCol + 1,
    flip_square_color(N, CurRow, CurCol, CurStates, FlippedCurInd),
    flip_square_color(N, CurRow, PrevCol, FlippedCurInd, FlippedPrevInd),
    flip_square_color(N, CurRow, NextCol, FlippedPrevInd, FlippedNextInd),
    flip_square_color(N, PrevRow, CurCol, FlippedNextInd, FlippedUpperInd),
    flip_square_color(N, NextRow, CurCol, FlippedUpperInd, FlippedAllSquares).

% row or col out of bound, no need to flip
flip_square_color(N, Row, Col, Unflipped, Unflipped) :-
    Row < 0;
    Col < 0;
    Row >= N;
    Col >= N.
% row and col inbound. flip.
flip_square_color(N, Row, Col, Unflipped, Flipped) :-
    Row >= 0,
    Col >= 0,
    Row < N,
    Col < N,
    get_index(N, Row, Col, Index),
    change_square_color(Unflipped, Index, Flipped).


% change_square_color(Original_list, Index, Swapped_list_.
% Swap the color when the desired index is reach.
change_square_color([Color|T], 0, [NewColor|T]) :-
    oppositeColor(Color, NewColor).
% Move to the next index.
change_square_color([H|T], Index, [H|R]) :-
    Index > 0,
    NewIndex is Index-1,
    change_square_color(T, NewIndex, R), !.
% Do nothing if index out of bound
change_square_color(L, Index, L) :-
    length(L, Len),
    Index >= Len
    ;  
    Index < 0.


% Get row, col of the square given its index
get_pos(N, Index, Row, Col) :-
    TotalLength is N*N,
    Index < TotalLength,
    Row is div(Index, N),
    Col is mod(Index, N).


% Get index of the square given its row, col
get_index(N, Row, Col, -1) :-
    Row < 0;
    Col < 0;
    Row >= N;
    Col >= N.
get_index(N, Row, Col, Index) :-
    Index is Row * N + Col.


% If a square at a given index is red
isRed(0, [red|_]).
isRed(Index, [_|Tail]) :-
    Next is Index - 1,
    isRed(Next, Tail).
    

% extra predicates. not used.
prev_row_all_red(N, CurRow, CurCol, CurStates) :-
    CurRow >= 1,
    CurCol is N - 1,
    PrevRow is CurRow - 1,
    get_index(N, PrevRow, 0, CompletedRowStart),
    get_index(N, PrevRow, CurCol, CompletedRowEnd),
    all_red_in_range(0, CompletedRowStart, CompletedRowEnd, CurStates).
prev_row_all_red(N, _CurRow, CurCol, _CurStates) :-
    \+CurCol is N - 1.


all_red_in_range(CompletedRowEnd, _CompletedRowStart, CompletedRowEnd, _CurStates).
all_red_in_range(Index, CompletedRowStart, CompletedRowEnd, [_|CurStatesTail]) :-
    Index < CompletedRowStart,
    NextIndex is Index + 1,
    all_red_in_range(NextIndex, CompletedRowStart, CompletedRowEnd, CurStatesTail).
all_red_in_range(Index, CompletedRowStart, CompletedRowEnd, [red|CurStatesTail]) :-
    Index >= CompletedRowStart,
    Index < CompletedRowEnd,
    NextIndex is Index + 1,
    all_red_in_range(NextIndex, CompletedRowStart, CompletedRowEnd, CurStatesTail).    
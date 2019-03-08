# Chess challenge (undo/redo design pattern)

You are provided with simple ETF starter project (in folder `bishop-chess`) to illustrate the undo/redo design pattern for a chess board with only two pieces, a king (K) and a bishop (B). The project should compile out of the box but is incomplete. The undo/redo design pattern is built on top of basic OO constructs such as static typing, dynamic binding and polymorphism. 

In job interviews with companies, students are often asked questions involving the movements of pieces such as kings, bishops or other game pieces. 

In a Labtest we might provide you with a similar starter and ask you to design a game with any two pieces taken from kings, bishops, rooks, and knights. In the `docs` folder see `chess_moves.e`. See:
`directions_of_player (player: CHARACTER): ARRAY[TUPLE[x: INTEGER; y: INTEGER]]`.

Please read and understand the design/code and ensure that you get it working. 


Ensure that you understand how these pieces move. The abstract algorithm for any piece is in class MOVE. 
 
## Model Cluster

![Model Cluster](docs/model-cluster.png)

In the starter project, the king moves on the board but not the bishop to give you some idea of the basic design. The deferred class MOVE* has a template pattern for moving different pieces on the board and also specifies deferred routines for undo and redo. Different pieces effect `directions` differently, to make use of polymorphism and dynamic binding. 

You will need to edit at least the foillowing:

* BOARD
* MOVE_BISHOP
* MOVE_KING
* ETF_MOVE\_BISHOP

## What you must do

Start by getting the acceptance test below working. Then write you own syntactically correct acceptance tests and ensure that the project (a) compiles and (b) is correct in all respects and (c) never crashes with exceptions, or non-termination. 

## The abtract grammar at the user interface

```
system chess
  -- just a King (K) and a Bishop (B) with undo/redo

type SIZE = 5..8
  -- size of board, e.g. 5 x 5

type SQUARE = TUPLE [x: 1..8; y: 1..8]

play(size: SIZE)
  -- create a board with `size` rows and `size` columns
  -- initially, the King is always at the top left [1,1] 
  -- and the Bishop is always at the bottom right [size, size]

 move_king(square: SQUARE)
   -- some moves not permitted
   -- either due to board size
   -- or because a square is occupied

 move_bishop(square: SQUARE)
   -- some moves not permitted
   -- either due to board size
   -- or because a square is occupied

 undo

 redo
```

## An example acceptance test

```
  ok, K = King and B = Bishop:
->play(5)
  ok:
  K____
  _____
  _____
  _____
  ____B
->play(8)
  game already started:
->move_bishop([4, 3])
  invalid move:
->move_bishop([1, 1])
  invalid move:
->move_bishop([2, 2])
  ok:
  K____
  _B___
  _____
  _____
  _____
->move_bishop([3, 1])
  ok:
  K____
  _____
  B____
  _____
  _____
->move_king([1, 8])
  invalid move:
->move_king([2, 2])
  ok:
  _____
  _K___
  B____
  _____
  _____
->move_king([3, 1])
  invalid move:
->move_king([3, 2])
  ok:
  _____
  _____
  BK___
  _____
  _____
->undo
  ok:
  _____
  _K___
  B____
  _____
  _____
->undo
  ok:
  K____
  _____
  B____
  _____
  _____
->undo
  ok:
  K____
  _B___
  _____
  _____
  _____
->undo
  ok:
  K____
  _____
  _____
  _____
  ____B
->undo
  no more to undo:
->redo
  ok:
  K____
  _B___
  _____
  _____
  _____
->redo
  ok:
  K____
  _____
  B____
  _____
  _____
->redo
  ok:
  _____
  _K___
  B____
  _____
  _____
->redo
  ok:
  _____
  _____
  BK___
  _____
  _____
->redo
  nothing to redo:
```




 
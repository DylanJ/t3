var Piece = function() {
  this.icon = null;
}

var BoardController = function() {
  this.size = 3;
  this.pieces = [];
  this.view = new BoardView(this);

  this.buildBoard();
}

BoardController.prototype.gameWon = function(winner) {
  if ( ttt.id == winner.id ) {
    ttt.alert.notice("You Win!")
  } else {
    ttt.alert.notice("You Lose!")
  }
};

BoardController.prototype.gameTied = function(winner) {
  console.log("tie");
};

BoardController.prototype.buildBoard = function() {
  for(i = 0; i < this.size*this.size; i++) {
    this.pieces.push(new Piece())
  }
};

BoardController.prototype.clickPiece = function(id) {
  console.log("piece clicked: " + id);
  send('move', { piece_id: id });
};

BoardController.prototype.move = function(turn) {
  this.view.move(turn);
};

BoardController.prototype.loadGame = function(game) {
  this.view.loadGame(game)
};

BoardController.prototype.leaveGame = function(game) {
  console.log("leaving game")
};

var BoardView = function(boardController) {
  controller = this.controller = boardController;

  this.boardNode = div({class: 'board'});
  this.boardPieceNodes = [];

  this.leaveButton = div({class: 'button'}, 'Leave Game');
  this.leaveButton.onclick = function() {
    controller.leaveGame()
  }

  this.scoreNode = this.createScoreNode();
}

BoardView.prototype.createScoreNode = function() {
  this.player1 = span({class: 'score'}, '0');
  this.player2 = span({class: 'score'}, '0');

  node = div({class: 'scores'},
    div('Player1: ', this.player1),
    div('Player2: ', this.player2)
  );

  return node;
}

BoardView.prototype.loadGame = function(game) {
  boardPieceNodes = this.boardPieceNodes

  boardPieceNodes.forEach(function(boardNode, i){
    boardNode.innerHTML = game.pieces[i]
  });
}

BoardView.prototype.createBoard = function() {
  pieces = this.controller.pieces;
  boardNode = this.boardNode;
  boardPieceNodes = [];
  controller = this.controller;

  pieces.forEach(function(piece, i) {
    the_controller = controller;

    boardPieceNode = div({class: 'piece'}, 'Empty');

    boardPieceNode.onclick = function() {
      the_controller.clickPiece(i);
    };

    boardNode.appendChild(boardPieceNode);
    boardPieceNodes.push(boardPieceNode);
  });

  this.boardPieceNodes = boardPieceNodes;
}

BoardView.prototype.move = function(turn) {
  this.boardPieceNodes[turn.piece_id].innerHTML = turn.symbol;
}

BoardView.prototype.draw = function() {
  this.createBoard();

  element = document.getElementById('app');
  element.appendChild(this.scoreNode);
  element.appendChild(this.boardNode);
  element.appendChild(this.leaveButton);

  console.log("drawing board");
}



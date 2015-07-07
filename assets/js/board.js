var Piece = function() {
  this.icon = null;
}

var BoardController = function() {
  this.size = 3
  this.pieces = []
  this.view = new BoardView(this)

  this.buildBoard()
}

BoardController.prototype.buildBoard = function() {
  for(i = 0; i < this.size*this.size; i++) {
    this.pieces.push(new Piece())
  }
}

BoardController.prototype.clickPiece = function(id) {
  console.log("piece clicked: " + id);
  send('move', { piece_id: id });
}

BoardController.prototype.move = function(turn) {
  this.view.move(turn)
}

var BoardView = function(boardController) {
  this.controller = boardController;

  this.boardNode = document.createElement('div');
  this.boardNode.classList.add('board');
  this.boardPieceNodes = [];
}

BoardView.prototype.createBoard = function() {
  pieces = this.controller.pieces;
  boardNode = this.boardNode;
  boardPieceNodes = [];
  controller = this.controller;

  pieces.forEach(function(piece, i) {
    boardPieceNode = document.createElement('div');
    boardPieceNode.classList.add('piece');
    boardPieceNode.appendChild(document.createTextNode('empty'));

    boardPieceNode.onclick = function() {
      controller.clickPiece(i);
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
  element.appendChild(this.boardNode);

  console.log("drawing board");
}

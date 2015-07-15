var Piece = function() {
  this.icon = null;
};

var BoardController = function(game) {
  this.game = game;
  this.pieces = [];
  this.players = {};
  this.view = new BoardView(this);
};

BoardController.prototype.gameOver = function(options) {
  var controller = this;
  this.game.gameOver(options, function() {
    controller.close();
    this.game.controllers.room_list.open();
  });
};

BoardController.prototype.startTurn = function(player_id) {
  if (player_id == this.game.getId()) {
    this.view.updateTurnText("Your turn!");
  } else {
    this.view.updateTurnText("Opponents turn.");
  }
};

BoardController.prototype.illegalMove = function() {
  this.view.updateTurnText("Cant do that!");
};

BoardController.prototype.gameStart = function(start_player_id, players) {
  this.updatePlayers(players);
  this.view.updatePlayerList();
  this.startTurn(start_player_id);
};

BoardController.prototype.leave = function() {
  this.game.send('leave', {});
  this.close();
};

BoardController.prototype.close = function() {
  this.view.close();
};

BoardController.prototype.playerJoined = function(player) {
  console.log('player joined');

  var id = player.id;

  this.players[id] = player;
  this.players[id].status = "Connected";

  this.view.updatePlayerList();
};

BoardController.prototype.playerDisconnected = function(player_id) {
  console.log('player disconnected');
  var player = this.players[player_id];

  if ( player !== undefined ) {
    player.status = "Disconnected";
    this.view.updatePlayerList();
  }
};

BoardController.prototype.playerQuit = function(player_id) {
  console.log('player disconnected');
  var player = this.players[player_id];

  if ( player !== undefined ) {
    player.status = "Quit";
    this.view.updatePlayerList();
  }
};

BoardController.prototype.gameWon = function(winner_id) {
  var message = "";
  if ( this.game.getId() == winner_id ) {
    message = "You Win!";
  } else {
    message = "You Lose!";
  }

  var callback = this.onClickFinishGame;
  this.game.alert(message, this.onClickFinishGame.bind(this));
};

BoardController.prototype.onClickFinishGame = function() {
  this.view.updateBoard();
  this.view.updatePlayerList();
};

BoardController.prototype.gameTie = function(winner) {
  this.game.alert("You Tied!", this.onClickFinishGame.bind(this));
};

BoardController.prototype.buildBoard = function(size) {
  this.size = size;
  this.pieces = [];
  this.players = {};

  for(i = 0; i < size*size; i++) {
    this.pieces.push(new Piece());
  }
};

BoardController.prototype.clickPiece = function(id) {
  console.log("piece clicked: " + id);
  this.game.send('move', { piece_id: id });
};

BoardController.prototype.move = function(turn) {
  this.view.move(turn);
};

BoardController.prototype.updatePlayers = function(players) {
  for(i = 0; i < players.length; i++) {
    var player = players[i];
    var id = player.id;

    this.players[id] = player;
  }
};

BoardController.prototype.loadGame = function(game) {
  this.pieces = game.pieces;
  this.updatePlayers(game.players);
  this.view.updateBoard();
  this.view.updatePlayerList();
};

BoardController.prototype.open = function(room) {
  console.log("opening a room");

  this.buildBoard(room.grid);
  this.view.updateBoard();
  this.view.updatePlayerList();
  this.view.add2dom();
};

var BoardView = function(boardController) {
  this.controller = boardController;
  this.boardNode = div({class: 'board'});
  this.infoNode = this.createInfoNode();

  this.optionsNode = div({class: 'options'}, this.createOptionsButton());

  this.gameContainerNode = div(
    div({class: 'game container'},
      this.infoNode,
      this.boardNode
    ),
    this.optionsNode
  );

  this.boardPieceNodes = [];
};

BoardView.prototype.updateBoard = function() {
  var pieceNodes = this.boardPieceNodes;

  for (i = 0; i < pieceNodes.length; i++) {
    pieceNodes[i].innerHTML = this.controller.pieces[i];
  }
};

BoardView.prototype.updatePlayerList = function() {
  var players = this.controller.players;
  var ids = Object.keys(players);

  this.clear(this.playersNode);

  for(i = 0; i < ids.length; i++) {
    var id = ids[i];
    var player = players[id];
    var playerNode = div({class: 'player'},
      dl(
        dt('Name'), dd(player.name),
        dt('Record'), dd(player.record),
        dt('Streak'), dd(player.streak),
        dt('Status'), dd(player.status)
      ),
      div({class: 'piece'}, player.icon)
    );

    this.playersNode.appendChild(playerNode);
  }
};

BoardView.prototype.createInfoNode = function() {
  var turnNode = this.turnNode = div({class: 'turn'}, 'Waiting for opponent to join.');
  var playersNode = this.playersNode = div({class: 'players'});
  var titleNode = this.titleNode = div({class: 'title'}, 'Player 1 vs Player 2');
  var topNode = div({class:'top'},
    titleNode,
    playersNode
  );

  return div({class: 'info'}, topNode, turnNode);
};

BoardView.prototype.updateTurnText = function(text) {
  this.turnNode.innerText = text;
};

BoardView.prototype.createScoreNode = function() {
  this.player1 = span({class: 'score'}, '0');
  this.player2 = span({class: 'score'}, '0');

  node = div({class: 'scores'},
    div('Player1: ', this.player1),
    div('Player2: ', this.player2)
  );

  return node;
};

BoardView.prototype.createBoard = function() {
  var pieces = this.controller.pieces;
  var boardNode = this.boardNode;
  var boardPieceNodes = [];
  var controller = this.controller;
  var size = controller.size;

  var tbodyNode = tbody();
  var tableNode = table(tbodyNode);

  var onclick = function(e) {
    id = e.target.getAttribute('piece-id');
    this.controller.clickPiece(id);
  };

  for(i = 0; i < size; i++ ) {
    var trNode = tr();

    for(j = 0; j < size; j++ ) {
      var piece = td({class: 'piece', 'piece-id': (i*size)+j, onclick: onclick, context: this});

      boardPieceNodes.push(piece);
      trNode.appendChild(piece);
    }

    tbodyNode.appendChild(trNode);
  }

//   pieces.forEach(function(piece, i) {
//     var the_controller = controller;
//     var boardPieceNode = div({class: 'piece'}, 'Empty');

//     boardPieceNode.onclick = function() {
//       the_controller.clickPiece(i);
//     };

//     boardNode.appendChild(boardPieceNode);
//     boardPieceNodes.push(boardPieceNode);
//   });

  this.boardPieceNodes = boardPieceNodes;
  this.boardNode.appendChild(tableNode);
};

BoardView.prototype.move = function(turn) {
  this.boardPieceNodes[turn.piece_id].innerHTML = turn.symbol;
};

BoardView.prototype.createOptionsButton = function() {
  var controller = this.controller;
  return div({class: 'button', onclick: function() {
    controller.leave();
  }}, 'Leave Game');
};

BoardView.prototype.add2dom = function() {
  this.createBoard();
  this.updatePlayerList();

  element = document.getElementById('app');
  element.appendChild(this.gameContainerNode);

  console.log("drawing board");
};

BoardView.prototype.close = function() {
  var parentNode = this.gameContainerNode.parentNode;

  if ( parentNode !== null ) {
    parentNode.removeChild(this.gameContainerNode);
  }

  this.clear(this.boardNode);
};

BoardView.prototype.clear = function(node) {
  while(node.firstChild) {
    node.removeChild(node.firstChild);
  }
};

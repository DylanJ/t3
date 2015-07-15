var Game = function (address) {
  "use strict";

  this.sock = new WebSocket(address);

  this.sock.onopen    = function () { game.onOpen(); };
  this.sock.onmessage = function (message) { game.onMessage(message); };
  this.sock.onerror   = function () { game.onError(); };

  this.controllers = {};

  this.controllers.room_list = new RoomListController(this);
  this.controllers.board = new BoardController(this);
  this.controllers.alert = new AlertController();
  this.controllers.status = new StatusController();
};

Game.prototype.send = function(command, options) {
  options.command = command;

  var data = JSON.stringify(options);
  this.sock.send(data);
};

Game.prototype.init = function() {
  this.controllers.room_list.view.update();

  if (this.getName() === null) {
    var game = this;

    game.prompt('Please choose a name', 'Register', function(name) {
      game.setName(name);
      game.register();
    });
  }

  this.controllers.status.view.add2dom();
};

Game.prototype.prompt = function(text, button, callback) {
  this.controllers.alert.prompt(text, button, callback);
};

Game.prototype.alert = function(text, callback) {
  this.controllers.alert.notice(text, callback);
};

Game.prototype.gameOver = function(info, callback) {
  this.controllers.alert.gameOver(info, callback);
};

Game.prototype.getId = function() {
  return sessionStorage.getItem('id');
};

Game.prototype.setId = function(id) {
  return sessionStorage.setItem('id', id);
};

Game.prototype.getName = function() {
  return sessionStorage.getItem('name');
};

Game.prototype.setName = function(name) {
  return sessionStorage.setItem('name', name);
};

Game.prototype.register = function() {
  var name = this.getName();
  var id = this.getId();
  var options = { name: name };

  if ( id !== null ) {
    options.id = id;
  }

  this.send('register', options);

  this.controllers.status.setName(this.getName());
};

// message events
Game.prototype.onError = function(error) {
  console.log("error: " + error);
};

Game.prototype.onOpen = function() {
  var name = this.getName();

  if (name !== null) {
    this.register(name);
  }
};

Game.prototype.onMessage = function(message) {
  var data = JSON.parse(message.data);

  console.log("received message");
  console.log(data);

  if (data.command == 'welcome') {
  }

  if (data.command == 'user_info') {
    this.setId(data.client.id);
  }
  if (data.command == 'room_added') {
    this.controllers.room_list.add(data.room);
  }
  if (data.command == 'room_removed') {
    this.controllers.room_list.remove(data.room_id);
  }
  if (data.command == 'room_list') {
    this.controllers.board.close();
    this.controllers.room_list.open();
    this.controllers.room_list.loadRoomList(data.rooms);
  }
  if (data.command == 'room_update') {
    this.controllers.room_list.updateRoom(data.room);
  }
  if (data.command == 'room_joined') {
    var room = data.room;

    console.log("joined room");
    console.log(room);

    this.controllers.room_list.close();
    this.controllers.board.open(room);
  }

  if (data.command == 'player_joined') {
    this.controllers.board.playerJoined(data.player);
  }
  if (data.command == 'player_disconnected') {
    this.controllers.board.playerDisconnected(data.player_id);
  }
  if (data.command == 'player_quit') {
    this.controllers.board.playerQuit(data.player_id);
  }
  if (data.command == 'game_start') {
    this.controllers.board.gameStart(data.start_player_id, data.players);
  }
  if (data.command == 'game_state') {
    this.controllers.board.loadGame(data.game);
  }
  if (data.command == 'game_turn') {
    this.controllers.board.startTurn(this.getId());
    this.controllers.board.move(data.turn);
  }
  if (data.command == 'game_over') {
    this.controllers.board.gameOver(data);
  }
  if (data.command == 'game_end') {
    if (data.result == 'win') {
      this.controllers.board.gameWon(data.winner_id);
    } else if (data.result == 'tie') {
      this.controllers.board.gameTie();
    }
  }

  if (data.command == 'illegal_move') {
    this.controllers.board.illegalMove();
  }
};


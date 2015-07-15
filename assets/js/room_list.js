var RoomListController = function(game) {
  'use strict';

  this.entries = [];
  this.view = new RoomListView(this);
  this.game = game;
};

RoomListController.prototype.updateRoom = function(room) {
  var id = -1;

  for (i = 0; i < this.entries.length; i++) {
    if (this.entries[i].id == room.id) {
      id = i;
      break;
    }
  }

  if ( id > -1 ) {
    this.entries[id] = room;
  }

  this.view.update();
};

RoomListController.prototype.open = function() {
  this.view.add2dom();
};

RoomListController.prototype.close = function() {
  this.view.close();
};

RoomListController.prototype.loadRoomList = function(rooms) {
  this.entries = [];

  for(i = 0; i < rooms.length; i++) {
    this.entries.push(rooms[i]);
  }

  this.view.update();
};

RoomListController.prototype.join = function(room) {
  this.game.send('room_join', { room_id: room.id });
};

RoomListController.prototype.createRoom = function(room) {
  this.game.send("room_create", room);
};

RoomListController.prototype.add = function(room) {
  this.entries.push(room);
  this.view.update();
};

RoomListController.prototype.remove = function(room_id) {
  var index = -1;
  for(i = 0; i < this.entries.length; i++) {
    if (this.entries[i].id == room_id) {
      index = i;
      break;
    }
  }

  if (index > -1) {
    this.entries.splice(index, 1);
  }

  this.view.update();
};

var RoomListView = function(roomListController) {
  this.controller = roomListController;

  this.roomListEntriesNode = div({class: 'entries'});
  this.roomListOptionsNode = div({class: 'options'});
  this.roomListNode = div(
    div({id: 'room-list', class: 'container'}, this.roomListEntriesNode),
    this.roomListOptionsNode
  );

  var btn = this.createRoomButton();
  this.roomListOptionsNode.appendChild(btn);
};

// renders the list of rooms
RoomListView.prototype.update = function() {
  this.clearList();

  var entries = this.controller.entries;

  this.roomListEntriesNode.appendChild(this.createTitle());
  this.roomListEntriesHash = {};

  if (entries.length === 0) {
    this.roomListEntriesNode.appendChild(div({class: 'entry empty nohover'}, 'Nobody currently playing! :('));
  } else {
    for(i = 0; i < entries.length; i++) {
      var roomEntry = entries[i];
      var entryElement = this.createEntry(roomEntry);

      this.roomListEntriesHash[roomEntry.id] = roomEntry;
      this.roomListEntriesNode.appendChild(entryElement);
    }
  }
};

RoomListView.prototype.add2dom = function() {

  this.update();

  element = document.getElementById('app');
  element.appendChild(this.roomListNode);
};

RoomListView.prototype.close = function() {
  var parentNode = this.roomListNode.parentNode;

  if ( parentNode !== null ) {
    parentNode.removeChild(this.roomListNode);
  }
};

RoomListView.prototype.createRoomButton = function() {
  var title = 'Enter a title for your room';
  var button = 'Create Room';
  var game = this.game;

  var createRoomFunc = function() {
    var controller = this.controller;

    controller.game.prompt(title, button, function(name) {
      controller.createRoom({name: name});
    });
  };

  return span({class: 'button', onclick: createRoomFunc, context: this}, 'Create Room');
};

RoomListView.prototype.clearList = function() {
  var node = this.roomListEntriesNode;

  while(node.firstChild) {
    node.removeChild(node.firstChild);
  }

  delete this.roomListEntriesHash;
  this.roomListEntriesHash = {};
};

RoomListView.prototype.createTitle = function() {
  var data = { name: 'Room Name', password: 'PW', size: 'Size', owner: 'Owner' };
  var element = this.createEntryNode(data);
  element.classList.add('title');
  element.classList.add('nohover');
  return element;
};


RoomListView.prototype.createEntryNode = function(room) {
  return div({class: 'entry'},
    span({class: 'name'}, room.name),
    span({class: 'password'}, room.password),
    span({class: 'size'}, room.size),
    span({class: 'owner'}, room.owner)
  );
};

// creates a line in the room list
RoomListView.prototype.createEntry = function(room) {
  controller = this.controller;

  element = this.createEntryNode(room);
  element.onclick = function() {
    controller.join(room);
  };

  return element;
};
//})();

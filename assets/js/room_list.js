var RoomListController = function() {
  this.entries = [];
  this.view = new RoomListView(this);
};

RoomListController.prototype.close = function() {
  this.view.close();
};

RoomListController.prototype.loadRoomList = function(rooms) {
  for(i = 0; i < rooms.length; i++) {
    this.entries.push(rooms[i]);
  }
};

RoomListController.prototype.join = function(room) {
  console.log("joining " + room.name);
  send('room_join', { room_id: room.id });
};

RoomListController.prototype.createRoom = function(room) {
  send("room_create", room);
};

var RoomListView = function(roomListController) {
  this.controller = roomListController;
  this.roomListNode = div({id: 'room-list'});
};

RoomListView.prototype.createRoomButton = function() {
  controller = this.controller;

  createRoomFunc = function() {
    controller.createRoom({name: 'derp'});
  }

  return div({class: 'button', onclick: createRoomFunc}, 'Create Room')
}

RoomListView.prototype.close = function() {
  if ( parentNode = this.roomListNode.parentNode ) {
    parentNode.removeChild(this.roomListNode);
  }
};

// clears the nodes in the list
RoomListView.prototype.clear = function() {
  node = this.roomListNode;

  while(node.firstChild) {
    node.removeNode(node.firstChild);
  }
}

RoomListView.prototype.createTitle = function() {
  data = { name: 'Room Name', password: 'PW', size: 'Size', owner: 'Owner' }
  element = this.createEntryNode(data);
  element.classList.add('title');
  return element;
}

// renders the list of rooms
RoomListView.prototype.populate = function() {
  entries = this.controller.entries

  this.roomListNode.appendChild(this.createTitle())

  for(i = 0; i < entries.length; i++) {
    entryElement = this.createEntry(entries[i])

    this.roomListNode.appendChild(entryElement)
  }
}

RoomListView.prototype.createEntryNode = function(room) {
  return div({class: 'entry'},
    span({class: 'name'}, room.name),
    span({class: 'password'}, room.password),
    span({class: 'size'}, room.size),
    span({class: 'owner'}, room.owner)
  );
}

// creates a line in the room list
RoomListView.prototype.createEntry = function(room) {
  controller = this.controller;

  element = this.createEntryNode(room);
  element.onclick = function() {
    controller.join(room);
  };

  return element;
}

RoomListView.prototype.draw = function() {
  this.clear()
  this.populate()

  this.roomListNode.appendChild(this.createRoomButton());

  element = document.getElementById('app')
  element.appendChild(this.roomListNode)
}

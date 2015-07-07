var RoomListController = function() {
  this.entries = []
  this.view = new RoomListView(this)
}

RoomListController.prototype.loadRoomList = function(rooms) {
  for(i = 0; i < rooms.length; i++) {
    this.entries.push(rooms[i])
  }
}

RoomListController.prototype.join = function(room) {
  console.log("joining " + room.name)
  send('room_join', { room_id: room.id })
}

var RoomListView = function(roomListController) {
  this.controller = roomListController
  this.roomListNode = document.createElement('div')
}

// clears the nodes in the list
RoomListView.prototype.clear = function() {
  node = this.roomListNode

  while(node.firstChild) {
    node.removeNode(node.firstChild)
  }
}

// renders the list of rooms
RoomListView.prototype.populate = function() {
  entries = this.controller.entries

  for(i = 0; i < entries.length; i++) {
    entryElement = this.createEntry(entries[i])

    this.roomListNode.appendChild(entryElement)
  }
}

// creates a line in the room list
RoomListView.prototype.createEntry = function(room) {
  controller = this.controller;

  element = document.createElement('div');
  element.classList.add('entry');

  element.appendChild(document.createTextNode(room.name));
  element.appendChild(document.createTextNode(room.password));
  element.appendChild(document.createTextNode(room.size));

  element.onclick = function() {
    controller.join(room);
  };

  return element;
}

RoomListView.prototype.draw = function() {
  this.clear()
  this.populate()

  element = document.getElementById('app')
  element.appendChild(this.roomListNode)
}

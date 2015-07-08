var StatusController = function() {
  this.name = "undefined";
  this.view = new StatusView(this);
}

StatusController.prototype.setName = function(name) {
  this.name = name;
  this.view.setName(name)
}

var StatusView = function(statusController) {
  this.controller = statusController;

  this.nameNode = span({class: 'name'}, this.controller.name);

  this.statusNode = div({id: 'status'},
    div({class:'inner'}, span('Logged in as: ', this.nameNode))
  );
}

StatusView.prototype.setName = function(name) {
  this.nameNode.innerText = name
}

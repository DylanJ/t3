var AlertController = function() {
  this.view = new AlertView(this);
};

AlertController.prototype.notice = function(text, callback) {
  this.view.notice(text, callback);
};

AlertController.prototype.prompt = function(text, buttonText, callback) {
  this.view.prompt(text, buttonText, callback);
};

AlertController.prototype.close = function() {
  this.view.close();
};

AlertController.prototype.gameOver = function(options, callback) {
  this.view.gameOver(options, callback);
};

var AlertView = function(alertController) {
  this.controller = alertController;
  this.alertNode = div({class: 'alert'});
};

AlertView.prototype.gameOver = function(options, callback) {
  var players = options.players;
  var winner = "Game Over";
  var closeCallback = callback;

  var playersNode = div({class: 'players'});

  for(i = 0; i < players.length; i++) {
    var player = players[i];
    var playerNode = div({class:'player'}, player.name, br(), player.record);

    playersNode.appendChild(playerNode);
  }

  var controller = this.controller;
  var gameOverNode = div({class: 'game_over'},
    div({class:'winner'}, winner),
    playersNode,
    div({class:'options'},
      div({class: 'button', onclick: function() {
        controller.close();
        closeCallback();
      }, context: this}, "Close")
    )
  );

  this.alertNode.appendChild(gameOverNode);
  this.add2dom();
};

AlertView.prototype.prompt = function(text, buttonText, callback) {
  var node = this.createPrompt(text, buttonText, callback);
  this.alertNode.appendChild(node);

  this.add2dom();
};

AlertView.prototype.notice = function(text, callback) {
  var node = this.createNotice(text, callback);

  this.alertNode.appendChild(node);

  this.add2dom();
};

AlertView.prototype.add2dom = function() {
  var app = document.getElementById('app');
  app.appendChild(this.alertNode);
};

AlertView.prototype.close = function() {
  var node = this.alertNode.firstChild;

  while(node !== null) {
    this.alertNode.removeChild(node);

    node = this.alertNode.firstChild;
  }

  var parentNode = this.alertNode.parentNode;

  if (parentNode !== null) {
    parentNode.removeChild(this.alertNode);
  }
};

AlertView.prototype.createNotice = function(text, callback) {
  var controller = this.controller;
  var okayCallback = callback;
  var okayButton = div({class: 'button', onclick: function() {
    controller.close();
    okayCallback();
  }, context: this}, text);

  return div({class: 'notice'}, text, br(), okayButton);
};

AlertView.prototype.createPrompt = function(text, buttonText, callback) {
  var textField = input({
    type: 'text',
    name: 'info',
    class: 'input',
    autofocus: 'yes',
    onkeyup: function(e) {
      if (e.keyCode == 13) {
        submit();
      }
    }
  });

  var controller = this.controller;
  var submit = function() {
    callback(textField.value);
    controller.close();
  };

  var innerNode = div({class: 'prompt'},
    div({class:'description'}, text),
    textField, br(),
    div({class:'center'},
      div({class:'button', onclick: submit}, buttonText)
    )
  );

  return innerNode;
};


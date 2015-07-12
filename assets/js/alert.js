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

var AlertView = function(alertController) {
  this.controller = alertController;
  this.alertNode = div({class: 'alert'});
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

    parentNode = this.alertNode.parentNode;
  }
};

AlertView.prototype.createNotice = function(text, callback) {
  var innerNode = div({class: 'notice'}, text, br());
  var controller = this.controller;
  var okayCallback = callback;
  var okayButton = div({class: 'button', onclick: function() {
    controller.close();
    okayCallback();
  }, context: this}, text);

  innerNode.appendChild(okayButton);

  return innerNode;
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


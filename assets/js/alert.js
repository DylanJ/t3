var AlertController = function() {
  this.view = new AlertView(this);
};

AlertController.prototype.notice = function(text) {
  this.view.notice(text);
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
  node = this.createPrompt(text, buttonText, callback);
  this.alertNode.appendChild(node);

  ttt.updateApp(this.alertNode);
};

AlertView.prototype.createButton = function(text, callback) {

  return buttonNode;
};

AlertView.prototype.notice = function(text) {
  node = this.createNotice(text);

  this.alertNode.appendChild(node);

  ttt.updateApp(this.alertNode);
};

AlertView.prototype.close = function() {
  while(node = this.alertNode.firstChild) {
    this.alertNode.removeChild(node)
  }

  if ( parentNode = this.alertNode.parentNode ) {
    parentNode.removeChild(this.alertNode);
  }
}

AlertView.prototype.createNotice = function(text) {
  innerNode = div({class: 'notice'}, text, br());

  controller = this.controller;
  okayButton = div({class: 'button', onclick: function() { controller.close() }}, text);

  innerNode.appendChild(okayButton);

  return innerNode;
};

AlertView.prototype.createPrompt = function(text, buttonText, callback) {
  nameField = input({
    type: 'text',
    name: 'info',
    class: 'input',
    autofocus: 'yes'
  });

  innerNode = div({class: 'prompt'},
    div({class:'description'}, text),
    nameField, br(),
    div({class:'center'},
      div({class:'button', onclick: function(){
        callback(nameField.value);
      }}, buttonText)
    )
  );

  return innerNode;
};


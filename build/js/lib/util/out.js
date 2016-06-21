var C, Message, c, colors, i, len, message, os, println, progress, prop, stdout,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

C = require('colors/safe');

prop = require('./prop');

os = require('os');

stdout = process.stdout;

println = function(s) {
  return stdout.write(s + os.EOL);
};

colors = ['green', 'grey', 'white', 'red', 'yellow'];

Message = (function() {
  prop(Message, 'string', {
    get: function() {
      return this.parts.join('');
    }
  });

  prop(Message, 'show', {
    get: function() {
      return console.log(this.string);
    }
  });

  function Message(msg) {
    this.warning = bind(this.warning, this);
    this["continue"] = bind(this["continue"], this);
    this.clear = bind(this.clear, this);
    this.eol = bind(this.eol, this);
    this.ifNewline = bind(this.ifNewline, this);
    this.thenEol = bind(this.thenEol, this);
    this.eolThen = bind(this.eolThen, this);
    this.msg = bind(this.msg, this);
    this.color = 'grey';
    this.parts = [];
    colors.forEach((function(_this) {
      return function(c) {
        return _this[c] = function(msg) {
          if (msg) {
            _this.parts.push(C[c](msg));
          } else {
            _this.color = c;
          }
          return _this;
        };
      };
    })(this));
    if (msg != null) {
      this.grey(msg);
    }
  }

  Message.prototype.msg = function(msg) {
    if (msg != null) {
      this[this.color](msg);
    }
    return this;
  };

  Message.prototype.eolThen = function(msg) {
    if (this.parts.length) {
      this.eol();
    }
    if (msg != null) {
      this.msg(msg);
    }
    return this;
  };

  Message.prototype.thenEol = function(msg) {
    if (msg != null) {
      this.parts.push(msg);
    }
    return this.eol();
  };

  Message.prototype.ifNewline = function(msg) {
    if (!this.parts.length) {
      this.msg(msg);
    }
    return this;
  };

  Message.prototype.eol = function() {
    println(this.string);
    this.parts = [];
    return this;
  };

  Message.prototype.clear = function() {
    this.parts = [];
    return this;
  };

  Message.prototype["continue"] = function(prefix, msg) {
    return this.ifNewline("> " + prefix).msg(" " + (this.task.summary()) + " ");
  };

  Message.prototype.warning = function(msg) {
    return this.eolThen().yellow(msg).eol();
  };

  return Message;

})();

message = new Message();

progress = function(msg) {
  return message.msg(msg);
};

for (i = 0, len = colors.length; i < len; i++) {
  c = colors[i];
  progress[c] = message[c];
}

progress.eol = message.eol;

progress.eolThen = message.eolThen;

progress.thenEol = message.thenEol;

progress.ifNewline = message.ifNewline;

progress.error = message.red;

progress.warning = message.warning;

module.exports = progress;

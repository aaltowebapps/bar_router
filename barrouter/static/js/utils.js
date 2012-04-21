var tpl;

tpl = {
  templates: {},
  loadTemplates: function(names, callback) {
    var loadTemplate,
      _this = this;
    if (!debug) {
      callback();
      return;
    }
    loadTemplate = function(index) {
      var name;
      name = names[index];
      return $.get(static_prefix + "templates/" + name + ".html", function(data) {
        _this.templates[name] = data;
        index++;
        if (index < names.length) {
          return loadTemplate(index);
        } else {
          return callback();
        }
      });
    };
    return loadTemplate(0);
  },
  get: function(name) {
    return this.templates[name];
  }
};

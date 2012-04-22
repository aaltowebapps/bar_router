
window.ResultsView = Backbone.View.extend({
  el: $("#content"),
  initialize: function() {
    this.template = _.template(tpl.get('result'));
    this.from = getUrlParam("from");
    this.to = getUrlParam("to");
    return this.model = void 0;
  },
  events: {
    "click .route a": "showOnMap"
  },
  render: function() {
    var _this = this;
    $("#loader").show();
    $("#basicMap").hide();
    $(this.el).html("");
    Reittiopas.route(this.from, this.to, function(results) {
      _this.model = results;
      _.each(results, function(result) {
        return $(_this.el).append(_this.template({
          route: result[0]
        }));
      });
      return $("#loader").hide();
    });
    return this;
  },
  showOnMap: function(event) {
    event.preventDefault();
    return app.resultmap(this.model[0][0]);
  }
});

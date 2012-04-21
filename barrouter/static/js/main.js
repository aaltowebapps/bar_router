var AppRouter, app;

app = void 0;

Backbone.View.prototype.close = function() {
  console.log("Closing view " + this);
  if (this.beforeClose) this.beforeClose();
  return this.undelegateEvents();
};

Backbone.View.prototype.navigateAnchor = function(event) {
  event.preventDefault();
  return app.navigate(event.currentTarget.getAttribute("href"), {
    trigger: true
  });
};

AppRouter = Backbone.Router.extend({
  initialize: function() {
    this.wgs84 = new OpenLayers.Projection("EPSG:4326");
    return this.s_mercator = new OpenLayers.Projection("EPSG:900913");
  },
  routes: {
    "": "index"
  },
  index: function() {
    var _this = this;
    return this.before(function() {
      return new IndexView().render();
    });
  },
  before: function(callback) {
    if (this.currentPage) this.currentPage.close();
    return this.currentPage = callback();
  }
});

tpl.loadTemplates(["index"], function() {
  var action, route, routes;
  routes = AppRouter.prototype.routes;
  for (route in routes) {
    action = routes[route];
    routes[route + "/"] = action;
  }
  AppRouter.prototype.routes = routes;
  app = new AppRouter();
  return Backbone.history.start();
});

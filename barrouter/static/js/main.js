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
    var mapnik;
    this.wgs84 = new OpenLayers.Projection("EPSG:4326");
    this.s_mercator = new OpenLayers.Projection("EPSG:900913");
    this.map = new OpenLayers.Map("basicMap");
    mapnik = new OpenLayers.Layer.OSM();
    this.vectors = new OpenLayers.Layer.Vector("Vector layer");
    this.map.addLayer(mapnik);
    this.map.addLayer(this.vectors);
    this.map.addControl(new OpenLayers.Control.DrawFeature(this.vectors, OpenLayers.Handler.Path));
    return this.located = false;
  },
  routes: {
    "": "index",
    "route/*splat": "results"
  },
  index: function() {
    var _this = this;
    return this.before(function() {
      return new IndexView().render();
    });
  },
  results: function() {
    var _this = this;
    return this.before(function() {
      return new ResultsView().render();
    });
  },
  resultmap: function(model) {
    var _this = this;
    return this.before(function() {
      return new ResultMapView({
        model: model
      }).render();
    });
  },
  before: function(callback) {
    if (this.currentPage) this.currentPage.close();
    return this.currentPage = callback();
  }
});

tpl.loadTemplates(["index", "result", "resultMap"], function() {
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

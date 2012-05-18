// Generated by CoffeeScript 1.3.1
var AppRouter, app;

app = void 0;

Backbone.View.prototype.navigateAnchor = function(event) {
  event.preventDefault();
  return app.navigate(event.currentTarget.getAttribute("href"), {
    trigger: true
  });
};

AppRouter = Backbone.Router.extend({
  initialize: function() {
    var drag;
    this.wgs84 = new OpenLayers.Projection("EPSG:4326");
    this.s_mercator = new OpenLayers.Projection("EPSG:900913");
    this.vectors = new OpenLayers.Layer.Vector("Vector layer");
    drag = new OpenLayers.Control.DragFeature(this.vectors, {
      autoActivate: true,
      onComplete: function(event) {
        var sm_coords;
        sm_coords = {
          lon: event.geometry.x,
          lat: event.geometry.y
        };
        return Reittiopas.reverseLocate(toWGS(sm_coords), function(data) {
          return $(event.id).val(data.name);
        });
      }
    });
    this.map = new OpenLayers.Map({
      theme: null,
      controls: [
        drag, new OpenLayers.Control.Attribution(), new OpenLayers.Control.TouchNavigation({
          dragPanOptions: {
            enableKinetcs: true
          }
        }), new OpenLayers.Control.Zoom(), new OpenLayers.Control.DrawFeature(this.vectors, OpenLayers.Handler.Path)
      ],
      layers: [
        new OpenLayers.Layer.OSM("OpenStreetMap", null, {
          transitionEffect: 'resize'
        }), this.vectors
      ],
      center: new OpenLayers.LonLat(742000, 5861000),
      zoom: 14
    });
    drag.activate();
    this.located = false;
    if (!debug) {
      $("head").append("<style type='text/css'>" + collated_stylesheets + "</style>");
    }
    $(".back").on("click", function(event) {
      window.history.back();
      return false;
    });
    return this.firstPage = true;
  },
  routes: {
    "": "index",
    "route/*splat": "results",
    "input/*splat": "input"
  },
  index: function() {
    return this.changePage(new IndexView());
  },
  results: function() {
    return this.changePage(new ResultsView());
  },
  input: function() {
    return this.changePage(new InputView());
  },
  changePage: function(page) {
    var transition;
    $(page.el).attr("data-role", "page");
    page.render();
    $("body").append($(page.el));
    transition = "slide";
    if (this.firstPage) {
      transition = "none";
      this.firstPage = false;
    }
    console.log(transition);
    $.mobile.changePage($(page.el), {
      changeHash: false,
      transition: transition
    });
    if (page.initMap) {
      return page.initMap();
    }
  }
});

tpl.loadTemplates(["searcher", "results", "result-item", "input", "favorite-item"], function() {
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

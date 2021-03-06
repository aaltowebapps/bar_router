// Generated by CoffeeScript 1.3.1
var AppRouter, app;

app = void 0;

Backbone.View.prototype.navigateAnchor = function(event) {
  event.preventDefault();
  return app.navigate(event.currentTarget.getAttribute("href"), {
    trigger: true
  });
};

Backbone.View.prototype.back = function(event) {
  app.route.removeAllFeatures();
  event.preventDefault();
  if (this.transition) {
    app.transition = this.transition;
  } else {
    app.transition = "slide";
  }
  app.historyBack = true;
  return window.history.back();
};

AppRouter = Backbone.Router.extend({
  initialize: function() {
    var drag;
    this.wgs84 = new OpenLayers.Projection("EPSG:4326");
    this.s_mercator = new OpenLayers.Projection("EPSG:900913");
    this.vectors = new OpenLayers.Layer.Vector("Vector layer");
    this.route = new OpenLayers.Layer.Vector("Route layer");
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
        }), new OpenLayers.Control.Zoom(), new OpenLayers.Control.DrawFeature(this.vectors, OpenLayers.Handler.Path), new OpenLayers.Control.DrawFeature(this.route, OpenLayers.Handler.Path)
      ],
      layers: [
        new OpenLayers.Layer.OSM("OpenStreetMap", null, {
          transitionEffect: 'resize'
        }), this.route, this.vectors
      ],
      center: new OpenLayers.LonLat(742000, 5861000),
      zoom: 14
    });
    drag.activate();
    this.located = false;
    this.currentPage = null;
    if (!debug) {
      $("head").append("<style type='text/css'>" + collated_stylesheets + "</style>");
    }
    this.historyBack = false;
    this.firstPage = true;
    this.pages = {};
    return this.transition = "slide";
  },
  routes: {
    "": "index",
    "route/*splat": "results",
    "input/*splat": "input"
  },
  index: function(data) {
    if (!this.pages.index) {
      this.pages.index = new IndexView();
      this.insertToDOM(this.pages.index);
    }
    if (data) {
      this.pages.index.updateLocationFields(data);
    }
    return this.changePage(this.pages.index);
  },
  results: function(update) {
    if (!this.pages.resultsView) {
      this.pages.resultsView = new ResultsView();
      this.insertToDOM(this.pages.resultsView);
    } else if (update === true) {
      this.pages.resultsView.updateModel();
    }
    return this.changePage(this.pages.resultsView);
  },
  input: function() {
    if (!this.pages.favoritesView) {
      this.pages.favoritesView = new InputView();
      this.insertToDOM(this.pages.favoritesView);
    } else {
      this.pages.favoritesView.updateParams();
    }
    return this.changePage(this.pages.favoritesView);
  },
  resultMap: function(model) {
    if (!this.pages.resultMap) {
      this.pages.resultMap = new ResultMapView({
        model: model
      });
      this.insertToDOM(this.pages.resultMap);
    } else {
      this.pages.resultMap.model = model;
      this.pages.resultMap.showOnMap();
    }
    return this.changePage(this.pages.resultMap);
  },
  insertToDOM: function(page) {
    $(page.el).attr("data-role", "page");
    page.render();
    return $("body").append($(page.el));
  },
  changePage: function(page) {
    var animate, transition;
    transition = app.transition;
    if (page.transition) {
      transition = page.transition;
    }
    if (this.firstPage || $.browser.opera) {
      transition = "none";
      this.firstPage = false;
    }
    animate = {
      changeHash: false,
      transition: transition
    };
    if (this.historyBack) {
      this.historyBack = false;
      animate.reverse = true;
    }
    app.transition = "slide";
    $.mobile.changePage($(page.el), animate);
    if (page.updateListview) {
      page.updateListview();
    }
    if (page.initMap) {
      page.initMap();
    }
    if (page.resizeMap) {
      page.resizeMap();
    }
    if (page.updateLocationFields) {
      return page.updateLocationFields();
    }
  }
});

$(function() {
  return tpl.loadTemplates(["searcher", "results", "result-item", "input", "favorite-item", "resultmap"], function() {
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
});

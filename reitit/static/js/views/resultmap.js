// Generated by CoffeeScript 1.3.1

window.ResultMapView = Backbone.View.extend({
  initialize: function() {
    var res,
      _this = this;
    this.template = _.template(tpl.get('resultmap'));
    res = function(event) {
      return _this.resizeMap(event);
    };
    return $(window).on("resize", res);
  },
  initMap: function() {
    return app.map.render($("#resultMap")[0]);
  },
  resizeMap: function(event) {
    var h;
    if (!this.neededSpace) {
      this.neededSpace = $(this.el).find(".header h1").height() + $(this.el).find(".content").height() + 55;
    }
    h = Math.max($(window).height() - this.neededSpace, 120);
    $("#resultMap").height(h + "px");
    return app.map.updateSize();
  },
  events: {
    "click .back": "back"
  },
  render: function() {
    $(this.el).html(this.template());
    return this.showOnMap();
  },
  showOnMap: function() {
    var _this = this;
    app.route.removeAllFeatures();
    return _.each(this.model.legs, function(leg) {
      var line, points, style;
      points = [];
      _.each(leg.locs, function(loc) {
        var sm_coords, wgs_coords;
        wgs_coords = {
          lon: loc.coord.x,
          lat: loc.coord.y
        };
        sm_coords = toSMercator(wgs_coords);
        centerMap(sm_coords, 12);
        return points.push(new OpenLayers.Geometry.Point(sm_coords.lon, sm_coords.lat));
      });
      line = new OpenLayers.Geometry.LineString(points);
      style = {
        strokeOpacity: 0.5,
        strokeWidth: 5
      };
      if (["1", "3", "4", "5"].indexOf(leg.type) !== -1) {
        style["strokeColor"] = "#0000ff";
      } else if (leg.type === "2") {
        style["strokeColor"] = "#00ff00";
      } else if (leg.type === "12") {
        style["strokeColor"] = "#ff0000";
      } else if (leg.type === "6") {
        style["strokeColor"] = "#ff8c00";
      }
      return app.route.addFeatures([new OpenLayers.Feature.Vector(line, null, style)]);
    });
  }
});

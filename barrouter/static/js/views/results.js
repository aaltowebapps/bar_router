
window.ResultsView = Backbone.View.extend({
  el: $("#content"),
  initialize: function() {
    this.template = _.template(tpl.get('result'));
    this.from = getUrlParam("from");
    this.to = getUrlParam("to");
    this.model = void 0;
    if (!app.located) {
      return Reittiopas.locate(this.from, function(data) {
        var pos;
        pos = data.coords.split(",");
        return centerMap(pos[0], pos[1]);
      });
    }
  },
  events: {
    "click .route a": "showOnMap"
  },
  render: function() {
    var _this = this;
    $("#loader").show();
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
    var model,
      _this = this;
    event.preventDefault();
    model = this.model[0][0];
    app.vectors.removeAllFeatures();
    return _.each(model.legs, function(leg) {
      var line, points, style;
      points = [];
      _.each(leg.locs, function(loc) {
        var point;
        point = new OpenLayers.LonLat(loc.coord.x, loc.coord.y).transform(app.wgs84, app.s_mercator);
        return points.push(new OpenLayers.Geometry.Point(point.lon, point.lat));
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
      return app.vectors.addFeatures([new OpenLayers.Feature.Vector(line, null, style)]);
    });
  }
});

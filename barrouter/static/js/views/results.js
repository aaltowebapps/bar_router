
window.ResultsView = Backbone.View.extend({
  el: $("#content"),
  initialize: function() {
    this.template = _.template(tpl.get('result'));
    this.from = getUrlParam("from");
    return this.to = getUrlParam("to");
  },
  asdf: function() {
    var _this = this;
    return Reittiopas.route(this.from, this.to, function(data) {
      _this.vectors.removeAllFeatures();
      return _.each(data.legs, function(leg) {
        var line, points, style;
        console.log(leg);
        points = [];
        _.each(leg.locs, function(point) {
          var loc;
          loc = new OpenLayers.LonLat(point.coord.x, point.coord.y).transform(app.wgs84, app.s_mercator);
          return points.push(new OpenLayers.Geometry.Point(loc.lon, loc.lat));
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
        return _this.vectors.addFeatures([new OpenLayers.Feature.Vector(line, null, style)]);
      });
    });
  },
  events: {
    "click #dummy": "render"
  },
  render: function() {
    var _this = this;
    $("#loader").show();
    $("#basicMap").hide();
    $(this.el).html("");
    Reittiopas.route(this.from, this.to, function(results) {
      console.log(results);
      _.each(results, function(result) {
        console.log(result);
        return $(_this.el).append(_this.template({
          route: result[0]
        }));
      });
      return $("#loader").hide();
    });
    return this;
  }
});

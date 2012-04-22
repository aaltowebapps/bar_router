
window.ResultMapView = Backbone.View.extend({
  el: $("#content"),
  initialize: function(data) {
    return this.template = _.template(tpl.get('resultMap'));
  },
  events: {
    "click #back": "back"
  },
  render: function() {
    var _this = this;
    $(this.el).html(this.template());
    $("#basicMap").show().css({
      height: "90%"
    });
    app.vectors.removeAllFeatures();
    _.each(this.model.legs, function(leg) {
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
    return this;
  },
  back: function(event) {
    return event.preventDefault();
  }
});

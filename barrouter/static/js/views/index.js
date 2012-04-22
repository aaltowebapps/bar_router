
window.IndexView = Backbone.View.extend({
  el: $("#content"),
  initialize: function() {
    return this.template = _.template(tpl.get('index'));
  },
  events: {
    "submit": "submit",
    "change #from": "updateFrom"
  },
  render: function() {
    var _this = this;
    $(this.el).html(this.template());
    $("#basicMap").show();
    $("#to").val("Kamppi");
    if (navigator.geolocation) {
      (function() {
        var fail, success;
        success = function(position) {
          return _this.geolocate(position);
        };
        fail = function() {
          return _this.dummyGeolocate();
        };
        return navigator.geolocation.getCurrentPosition(success, fail);
      })();
    } else {
      dummyGeolocate();
    }
    return this;
  },
  submit: function(event) {
    var from, to;
    event.preventDefault();
    from = encodeURI(event.target[0].value);
    to = encodeURI(event.target[1].value);
    return app.navigate("/route/?from=" + from + "&to=" + to, true);
  },
  updateFrom: function(event) {
    var _this = this;
    return Reittiopas.locate(event.currentTarget.value, function(data) {
      var center, pos;
      if (data.details.houseNumber) {
        $("#from").val("" + data.name + " " + data.details.houseNumber + ", " + data.city);
      } else {
        $("#from").val("" + data.name + ", " + data.city);
      }
      pos = data.coords.split(",");
      center = new OpenLayers.LonLat(pos[0], pos[1]).transform(app.wgs84, app.s_mercator);
      _this.currentLocation.move(center);
      return centerMap(pos[0], pos[1]);
    });
  },
  geolocate: function(position) {
    var center, drag, geometryPoint, lat, lon;
    lon = position.coords.longitude;
    lat = position.coords.latitude;
    centerMap(lon, lat);
    center = new OpenLayers.LonLat(lon, lat).transform(app.wgs84, app.s_mercator);
    Reittiopas.reverseLocate(center.lon, center.lat, function(data) {
      return $("#from").val(data.name);
    });
    geometryPoint = new OpenLayers.Geometry.Point(center.lon, center.lat);
    this.currentLocation = new OpenLayers.Feature.Vector(geometryPoint);
    app.vectors.addFeatures([this.currentLocation]);
    drag = new OpenLayers.Control.DragFeature(app.vectors, {
      autoActivate: true,
      onComplete: function(event) {
        return Reittiopas.reverseLocate(event.geometry.x, event.geometry.y, function(data) {
          return $("#from").val(data.name);
        });
      }
    });
    app.map.addControl(drag);
    drag.activate();
  },
  dummyGeolocate: function() {
    return this.geolocate({
      coords: {
        longitude: 24.829577200463,
        latititude: 60.183374850576
      }
    });
  }
});

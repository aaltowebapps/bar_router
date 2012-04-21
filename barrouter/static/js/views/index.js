var reverseLocate;

window.IndexView = Backbone.View.extend({
  el: $("#content"),
  initialize: function() {
    this.template = _.template(tpl.get('index'));
    return this.map = void 0;
  },
  events: {
    "submit": "submit"
  },
  render: function() {
    var mapnik,
      _this = this;
    $(this.el).html(this.template());
    $("#to").val("Kamppi");
    this.map = new OpenLayers.Map("basicMap");
    mapnik = new OpenLayers.Layer.OSM();
    this.map.addLayer(mapnik);
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
    event.preventDefault();
    return alert("moi");
  },
  geolocate: function(position) {
    var center, drag, lat, lon, point, vectors;
    lon = position.coords.longitude;
    lat = position.coords.latitude;
    center = new OpenLayers.LonLat(lon, lat).transform(app.wgs84, app.s_mercator);
    reverseLocate(center.lon, center.lat, function(data) {
      return $("#from").val(data.name);
    });
    vectors = new OpenLayers.Layer.Vector("Vector layer");
    point = new OpenLayers.Geometry.Point(center.lon, center.lat);
    vectors.addFeatures([new OpenLayers.Feature.Vector(point)]);
    drag = new OpenLayers.Control.DragFeature(vectors, {
      autoActivate: true,
      onComplete: function(event) {
        return reverseLocate(event.geometry.x, event.geometry.y, function(data) {
          return $("#from").val(data.name);
        });
      }
    });
    this.map.addControl(drag);
    drag.activate();
    this.map.addLayer(vectors);
    this.map.setCenter(center, 15);
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

reverseLocate = function(x, y, callback) {
  var pos;
  pos = new OpenLayers.LonLat(x, y).transform(app.s_mercator, app.wgs84);
  return $.ajax({
    method: "GET",
    url: "/api/query/",
    data: {
      coordinate: "" + pos.lon + "," + pos.lat,
      request: "reverse_geocode"
    },
    success: function(data) {
      console.log("http://api.reittiopas.fi/hsl/prod/?user=aaltoreittiopas&pass=m33p1qRA&request=reverse_geocode&coordinate=" + pos.lon + "," + pos.lat + "&epsg_out=wgs84&epsg_in=wgs84");
      return callback(data[0]);
    }
  });
};

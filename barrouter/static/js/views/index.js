var locate, reverseLocate, route;

window.IndexView = Backbone.View.extend({
  el: $("#content"),
  initialize: function() {
    this.template = _.template(tpl.get('index'));
    return this.map = void 0;
  },
  events: {
    "submit": "submit",
    "change #from": "updateFrom"
  },
  render: function() {
    var mapnik,
      _this = this;
    $(this.el).html(this.template());
    $("#to").val("Kamppi");
    this.map = new OpenLayers.Map("basicMap");
    mapnik = new OpenLayers.Layer.OSM();
    this.vectors = new OpenLayers.Layer.Vector("Vector layer");
    this.map.addLayer(mapnik);
    this.map.addLayer(this.vectors);
    this.map.addControl(new OpenLayers.Control.DrawFeature(this.vectors, OpenLayers.Handler.Path));
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
    var _this = this;
    event.preventDefault();
    return route(event.target[0].value, event.target[1].value, function(data) {
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
  updateFrom: function(event) {
    var _this = this;
    return locate(event.currentTarget.value, function(data) {
      var center, pos;
      if (data.details.houseNumber) {
        $("#from").val("" + data.name + " " + data.details.houseNumber + ", " + data.city);
      } else {
        $("#from").val("" + data.name + ", " + data.city);
      }
      pos = data.coords.split(",");
      center = new OpenLayers.LonLat(pos[0], pos[1]).transform(app.wgs84, app.s_mercator);
      _this.currentLocation.move(center);
      return _this.map.setCenter(center, 15);
    });
  },
  geolocate: function(position) {
    var center, drag, geometryPoint, lat, lon;
    lon = position.coords.longitude;
    lat = position.coords.latitude;
    center = new OpenLayers.LonLat(lon, lat).transform(app.wgs84, app.s_mercator);
    reverseLocate(center.lon, center.lat, function(data) {
      return $("#from").val(data.name);
    });
    geometryPoint = new OpenLayers.Geometry.Point(center.lon, center.lat);
    this.currentLocation = new OpenLayers.Feature.Vector(geometryPoint);
    this.vectors.addFeatures([this.currentLocation]);
    drag = new OpenLayers.Control.DragFeature(this.vectors, {
      autoActivate: true,
      onComplete: function(event) {
        return reverseLocate(event.geometry.x, event.geometry.y, function(data) {
          return $("#from").val(data.name);
        });
      }
    });
    this.map.addControl(drag);
    drag.activate();
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

locate = function(key, callback) {
  return $.ajax({
    method: "GET",
    url: "/api/query",
    data: {
      key: key,
      request: "geocode"
    },
    success: function(data) {
      return callback(data[0]);
    }
  });
};

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

route = function(from, to, callback) {
  return $.ajax({
    method: "GET",
    url: "/api/query",
    data: {
      request: "route",
      from: from,
      to: to
    },
    success: function(data) {
      return callback(data[0][0]);
    }
  });
};

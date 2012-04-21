var error, reverseLocate, s_mercator, success, wgs84;

wgs84 = new OpenLayers.Projection("EPSG:4326");

s_mercator = new OpenLayers.Projection("EPSG:900913");

success = function(position) {
  var center, drag, lat, lon, map, mapnik, point, vectors;
  lon = position.coords.longitude;
  lat = position.coords.latitude;
  console.log(lon);
  console.log(lat);
  map = new OpenLayers.Map("basicMap");
  mapnik = new OpenLayers.Layer.OSM();
  vectors = new OpenLayers.Layer.Vector("Vector layer");
  map.addLayer(mapnik);
  center = new OpenLayers.LonLat(lon, lat).transform(wgs84, s_mercator);
  reverseLocate(center.lon, center.lat, function(data) {
    return $("#from").val(data.name);
  });
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
  map.addControl(drag);
  drag.activate();
  map.addLayer(vectors);
  return map.setCenter(center, 15);
};

error = function(message) {
  return $("#basicMap").html = message;
};

reverseLocate = function(x, y, callback) {
  var pos;
  pos = new OpenLayers.LonLat(x, y).transform(s_mercator, wgs84);
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

$(function() {
  if (navigator.geolocation) {
    return navigator.geolocation.getCurrentPosition(success, error);
  } else {
    return error("not supported");
  }
});
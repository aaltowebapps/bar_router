var Reittiopas;

Reittiopas = {
  locate: function(key, callback) {
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
  },
  reverseLocate: function(x, y, callback) {
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
        return callback(data[0]);
      }
    });
  },
  route: function(from, to, callback) {
    return $.ajax({
      method: "GET",
      url: "/api/query/",
      data: {
        request: "route",
        from: from,
        to: to
      },
      success: function(data) {
        return callback(data);
      }
    });
  }
};

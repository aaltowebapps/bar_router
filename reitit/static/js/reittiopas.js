// Generated by CoffeeScript 1.3.1
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
  reverseLocate: function(coords, callback) {
    return $.ajax({
      method: "GET",
      url: "/api/query/",
      data: {
        coordinate: "" + coords.lon + "," + coords.lat,
        request: "reverse_geocode"
      },
      success: function(data) {
        return callback(data[0]);
      }
    });
  },
  route: function(data, callback) {
    data.request = "route";
    data.detail = "full";
    data.show = 5;
    return $.ajax({
      method: "GET",
      url: "/api/query/",
      data: data,
      success: function(data) {
        return callback(data);
      }
    });
  }
};

wgs84 = new OpenLayers.Projection("EPSG:4326")
s_mercator = new OpenLayers.Projection("EPSG:900913")


success = (position) ->
    lon = position.coords.longitude
    lat = position.coords.latitude
    console.log lon
    console.log lat
    
    map = new OpenLayers.Map("basicMap")
    mapnik = new OpenLayers.Layer.OSM()
    vectors = new OpenLayers.Layer.Vector("Vector layer")

    map.addLayer mapnik

    center = new OpenLayers.LonLat(lon, lat).transform(wgs84, s_mercator)
    
    reverseLocate center.lon, center.lat, (data) ->
        $("#from").val data.name


    point = new OpenLayers.Geometry.Point(center.lon, center.lat)
    vectors.addFeatures [ new OpenLayers.Feature.Vector(point) ]
    drag = new OpenLayers.Control.DragFeature(vectors,
        autoActivate: true
        onComplete: (event) ->
            reverseLocate event.geometry.x, event.geometry.y, (data) ->
                $("#from").val data.name
    )
    map.addControl drag
    drag.activate()
    map.addLayer vectors
    map.setCenter center, 15

error = (message) ->
    $("#basicMap").html = message


reverseLocate = (x, y, callback) ->
    pos = new OpenLayers.LonLat(x, y)
        .transform(s_mercator, wgs84)

    $.ajax
        method: "GET"
        url: "/api/query/"
        data:
            coordinate: "#{pos.lon},#{pos.lat}"
            request: "reverse_geocode"
        success: (data) ->
            console.log "http://api.reittiopas.fi/hsl/prod/?user=aaltoreittiopas&pass=m33p1qRA&request=reverse_geocode&coordinate=" + pos.lon + "," + pos.lat + "&epsg_out=wgs84&epsg_in=wgs84"
            callback(data[0])


$ ->
    if navigator.geolocation
        navigator.geolocation.getCurrentPosition success, error
    else
        error "not supported"

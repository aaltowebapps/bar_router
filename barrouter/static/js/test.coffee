success = (position) ->
    lon = position.coords.longitude
    lat = position.coords.latitude
    
    wgs84 = new OpenLayers.Projection("EPSG:4326")
    s_mercator = new OpenLayers.Projection("EPSG:900913")
    

    map = new OpenLayers.Map("basicMap")
    mapnik = new OpenLayers.Layer.OSM()
    vectors = new OpenLayers.Layer.Vector("Vector layer")

    map.addLayer mapnik

    center = new OpenLayers.LonLat(lon, lat).transform(wgs84, s_mercator)
    point = new OpenLayers.Geometry.Point(center.lon, center.lat)
    vectors.addFeatures [ new OpenLayers.Feature.Vector(point) ]
    drag = new OpenLayers.Control.DragFeature(vectors,
        autoActivate: true
        onComplete: (event) ->
            pos = new OpenLayers.LonLat(event.geometry.x, event.geometry.y)
                .transform(s_mercator, wgs84)

            $.ajax
                method: "GET"
                url: "/api/query/"
                data:
                    lon: pos.lon
                    lat: pos.lat
                    to: "Kamppi"
                success: (data) ->
                    console.log data
                    alert data[0].name

            console.log "http://api.reittiopas.fi/hsl/prod/?user=aaltoreittiopas&pass=m33p1qRA&request=reverse_geocode&coordinate=" + pos.lon + "," + pos.lat + "&epsg_out=wgs84&epsg_in=wgs84"
    )
    map.addControl drag
    drag.activate()
    map.addLayer vectors
    map.setCenter center, 15


error = (message) ->
    $("#basicMap").html = message

$ ->
    if navigator.geolocation
        navigator.geolocation.getCurrentPosition success, error
    else
        error "not supported"

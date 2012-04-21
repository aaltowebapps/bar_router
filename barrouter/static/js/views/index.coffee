window.IndexView = Backbone.View.extend
    el: $("#content")

    initialize: ->
        @template = _.template tpl.get('index')
        @map = undefined

    events:
        "submit": "submit"

    render: ->
        $(@el).html @template()
        $("#to").val "Kamppi"

        @map = new OpenLayers.Map("basicMap")
        mapnik = new OpenLayers.Layer.OSM()

        @map.addLayer mapnik
        
        if navigator.geolocation
            do () =>
                success = (position) =>
                    @geolocate(position)
                fail = () =>
                    @dummyGeolocate()
                navigator.geolocation.getCurrentPosition success, fail
        else
            dummyGeolocate()

        return @

    submit: (event) ->
        event.preventDefault()
        alert "moi"


    geolocate: (position) ->
        lon = position.coords.longitude
        lat = position.coords.latitude

        center = new OpenLayers.LonLat(lon, lat).transform(app.wgs84, app.s_mercator)

        reverseLocate center.lon, center.lat, (data) ->
            $("#from").val data.name
        vectors = new OpenLayers.Layer.Vector("Vector layer")

        point = new OpenLayers.Geometry.Point(center.lon, center.lat)
        vectors.addFeatures [ new OpenLayers.Feature.Vector(point) ]
        drag = new OpenLayers.Control.DragFeature(vectors,
            autoActivate: true
            onComplete: (event) ->
                reverseLocate event.geometry.x, event.geometry.y, (data) ->
                    $("#from").val data.name
        )
        @map.addControl drag
        drag.activate()
        @map.addLayer vectors
        @map.setCenter center, 15
        return undefined

    dummyGeolocate: ->
        @geolocate
            coords:
                longitude: 24.829577200463
                latititude: 60.183374850576



reverseLocate = (x, y, callback) ->
    pos = new OpenLayers.LonLat(x, y)
        .transform(app.s_mercator, app.wgs84)

    $.ajax
        method: "GET"
        url: "/api/query/"
        data:
            coordinate: "#{pos.lon},#{pos.lat}"
            request: "reverse_geocode"
        success: (data) ->
            console.log "http://api.reittiopas.fi/hsl/prod/?user=aaltoreittiopas&pass=m33p1qRA&request=reverse_geocode&coordinate=" + pos.lon + "," + pos.lat + "&epsg_out=wgs84&epsg_in=wgs84"
            callback(data[0])

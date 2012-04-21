window.IndexView = Backbone.View.extend
    el: $("#content")

    initialize: ->
        @template = _.template tpl.get('index')
        @map = undefined

    events:
        "submit": "submit"
        "change #from": "updateFrom"

    render: ->
        $(@el).html @template()
        $("#to").val "Kamppi"

        @map = new OpenLayers.Map("basicMap")
        mapnik = new OpenLayers.Layer.OSM()
        @vectors = new OpenLayers.Layer.Vector("Vector layer")
        @currentPosition = undefined

        @map.addLayer mapnik
        @map.addLayer @vectors
        
        if navigator.geolocation
            # awesome closures
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
        route event.target[0].value, event.target[1].value, (data) ->
            console.log data

        
    
    updateFrom: (event) ->
        locate event.currentTarget.value, (data) =>
            if data.details.houseNumber
                $("#from").val "#{data.name} #{data.details.houseNumber}, #{data.city}"
            else
                $("#from").val "#{data.name}, #{data.city}"
            
            pos = data.coords.split(",")
            center = new OpenLayers.LonLat(pos[0],pos[1]).transform(app.wgs84, app.s_mercator)
            @currentLocation.move(center)
            @map.setCenter center, 15



    geolocate: (position) ->
        lon = position.coords.longitude
        lat = position.coords.latitude

        center = new OpenLayers.LonLat(lon, lat).transform(app.wgs84, app.s_mercator)

        reverseLocate center.lon, center.lat, (data) ->
            $("#from").val data.name

        geometryPoint = new OpenLayers.Geometry.Point(center.lon, center.lat)
        @currentLocation = new OpenLayers.Feature.Vector(geometryPoint)
        @vectors.addFeatures [ @currentLocation ]
        drag = new OpenLayers.Control.DragFeature(@vectors,
            autoActivate: true
            onComplete: (event) ->
                reverseLocate event.geometry.x, event.geometry.y, (data) ->
                    $("#from").val data.name
        )
        @map.addControl drag
        drag.activate()
        @map.setCenter center, 15
        return undefined

    dummyGeolocate: ->
        @geolocate
            coords:
                longitude: 24.829577200463
                latititude: 60.183374850576



locate = (key, callback) ->
    $.ajax
        method: "GET"
        url: "/api/query"
        data:
            key: key
            request: "geocode"
        success: (data) ->
            callback(data[0])
    

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


route = (from, to, callback) ->
    $.ajax
        method: "GET"
        url: "/api/query"
        data:
            request: "route"
            from: from
            to: to
        success: (data) ->
            callback data[0]

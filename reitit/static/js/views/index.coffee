window.IndexView = Backbone.View.extend
    el: $("#content")

    initialize: ->
        @template = _.template tpl.get('index')

    events:
        "submit": "submit"
        "change #from": "updateFrom"
        "click #from": "centerMapByFocusedInput"
        "click #to": "centerMapByFocusedInput"

    render: ->
        d = new Date()
        time =
            hours: d.getHours()
            minutes: d.getMinutes()

        $(@el).html @template({time:time})
        $("#basicMap").show()
        $("#to").val "Kamppi"

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
        from = encodeURI(event.target[0].value)
        to = encodeURI(event.target[1].value)
        time = encodeURI(event.target[2].value + event.target[3].value)
        timetype = encodeURI(event.target[4].id)
        app.navigate "/route/?from=#{from}&to=#{to}&time=#{time}&timetype=#{timetype}", true

    centerMapByFocusedInput: (event) ->
        Reittiopas.locate event.currentTarget.value, (data) =>
            pos = data.coords.split(",")
            center = new OpenLayers.LonLat(pos[0],pos[1]).transform(app.wgs84, app.s_mercator)
            centerMap(pos[0], pos[1]) 

    updateFrom: (event) ->
        Reittiopas.locate event.currentTarget.value, (data) =>
            if data.details.houseNumber
                $("#from").val "#{data.name} #{data.details.houseNumber}, #{data.city}"
            else
                $("#from").val "#{data.name}, #{data.city}"
            
            pos = data.coords.split(",")
            
            center = new OpenLayers.LonLat(pos[0],pos[1]).transform(app.wgs84, app.s_mercator)
            @currentLocation.move(center)
            centerMap(pos[0], pos[1])

    geolocate: (position) ->
        lon = position.coords.longitude
        lat = position.coords.latitude

        centerMap(lon, lat)

        center = new OpenLayers.LonLat(lon, lat).transform(app.wgs84, app.s_mercator)

        Reittiopas.reverseLocate center.lon, center.lat, (data) ->
            $("#from").val data.name

        geometryPoint = new OpenLayers.Geometry.Point(center.lon, center.lat)
        @currentLocation = new OpenLayers.Feature.Vector(geometryPoint)
        app.vectors.addFeatures [ @currentLocation ]
        drag = new OpenLayers.Control.DragFeature(app.vectors,
            autoActivate: true
            onComplete: (event) ->
                Reittiopas.reverseLocate event.geometry.x, event.geometry.y, (data) ->
                    $("#from").val data.name
        )
        app.map.addControl drag
        drag.activate()
        return undefined

    dummyGeolocate: ->
        @geolocate
            coords:
                longitude: 24.829577200463
                latititude: 60.183374850576

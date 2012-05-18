window.IndexView = Backbone.View.extend

    initialize: ->
        @template = _.template tpl.get('searcher')

    initMap: ->
        app.map.render $("#basicMap")[0]
        @resizeMap()
        #TODO remove this on view close
        $(window).on "resize", @resizeMap
        
    resizeMap: ->
        h = $(window).height() - $("#header h1").height() - $("#content").height() - 55
        h = Math.max(h, 120)
        $("#basicMap").height(h + "px")
        app.map.updateSize()

    events:
        "submit": "submit"
        "change #from": "updateFrom"
        "change #to": "updateTo"
        "focus #from": "onFocusedFrom"
        "focus #to": "onFocusedTo"
        "click #favfrom": "favToggleFrom"
        "click #favto": "favToggleTo"

    render: ->
        d = new Date()
        time =
            hours: d.getHours()
            minutes: d.getMinutes()

        $(@el).html @template({time:time})

        Reittiopas.locate "Kamppi", (data) =>
            if data.details.houseNumber
                $("#to").val "#{data.name} #{data.details.houseNumber}, #{data.city}"
            else
                $("#to").val "#{data.name}, #{data.city}"
            
            pos = data.coords.split(",")
            wgs_coords =
                lon: pos[0]
                lat: pos[1]

            sm_coords = toSMercator wgs_coords
            @currentToLocation = @initDragPoint sm_coords, "#to"

        if navigator.geolocation
            # awesome closures
            do () =>
                success = (position) =>
                    @geolocate(position)
                fail = () =>
                    @dummyGeolocate()
                navigator.geolocation.getCurrentPosition success, fail
        else
            @dummyGeolocate()


        return @

    submit: (event) ->
        event.preventDefault()
        from = encodeURI(event.target[0].value)
        to = encodeURI(event.target[1].value)
        time = encodeURI(event.target[2].value + event.target[3].value)
        timetype = encodeURI(event.target[4].value)
        app.navigate "/route/?from=#{from}&to=#{to}&time=#{time}&timetype=#{timetype}", true

    onFocusedFrom: (event) ->
        coords = new OpenLayers.LonLat @currentFromLocation.geometry.x, @currentFromLocation.geometry.y
        centerMap coords
#        from = encodeURI(event.currentTarget.value)
#        app.navigate "/input/?value=#{from}", true

    onFocusedTo: (event) ->
        coords = new OpenLayers.LonLat @currentToLocation.geometry.x, @currentToLocation.geometry.y
        centerMap coords

    updateFrom: (event) ->
        @updatePosition event.currentTarget.value, "#from", @currentFromLocation
        return undefined

    updateTo: (event) ->
        @updatePosition event.currentTarget.value, "#to", @currentToLocation
        return undefined

    updatePosition: (searchAddress, targetTextBox, targetDragVector) ->
        Reittiopas.locate searchAddress, (data) =>
            if data.details.houseNumber
                $(targetTextBox).val "#{data.name} #{data.details.houseNumber}, #{data.city}"
            else
                $(targetTextBox).val "#{data.name}, #{data.city}"
            
            pos = data.coords.split(",")
            wgs_coords =
                lon: pos[0]
                lat: pos[1]

            sm_coords = toSMercator wgs_coords

            targetDragVector.move sm_coords
            centerMap sm_coords

        return undefined

    geolocate: (position) ->
        wgs_coords =
            lon: position.coords.longitude
            lat: position.coords.latitude

        sm_coords = toSMercator wgs_coords
        centerMap sm_coords
        app.located = true
        @currentFromLocation = @initDragPoint sm_coords, "#from"

        Reittiopas.reverseLocate wgs_coords, (data) ->
            $("#from").val data.name

        return undefined

    dummyGeolocate: ->
        @geolocate
            coords:
                longitude: 24.829577200463
                latititude: 60.183374850576

    initDragPoint: (location, targetTextBox) ->
        geometryPoint = new OpenLayers.Geometry.Point(location.lon, location.lat)
        style =
            fillColor: "#ee0000"
            fillOpacity: 0.4
            strokeColor: "#ff0000"
            pointRadius: 6

        dragpoint = new OpenLayers.Feature.Vector(geometryPoint, null, style)
        dragpoint.id = targetTextBox
        app.vectors.addFeatures [ dragpoint ]
        
        return dragpoint

    # Handles a favorites toggle for the given direction, "from" or "to"
    favToggle: (direction) ->
        el = $("#fav" + direction)[0]
        enabled = el.src.contains "off"
        if enabled then el.src = el.src.replace("off", "on")
        else el.src = el.src.replace("on", "off")

        address = $("#" + direction)[0].value
        if enabled then Favorites.add(address)
        else Favorites.remove(address)
        return enabled

    favToggleFrom: (event) ->
        event.preventDefault()
        @favToggle("from")
        return undefined

    favToggleTo: (event) ->
        event.preventDefault()
        @favToggle("to")
        return undefined

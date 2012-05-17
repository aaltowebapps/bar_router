window.IndexView = Backbone.View.extend
#    el: $("#content")

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
        "focus #from": "centerMapByFocusedInput"
        "focus #to": "centerMapByFocusedInput"

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
            
#            pos = data.coords.split(",")
#            wgs_coors =
#                lon: pos[0]
#                lat: pos[1]
#
#            sm_coords = toSMercator wgs_coords
#            @currentToLocation = @initDragPoint sm_coords, "#to"

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
        console.log(event.target[4].value)
        timetype = encodeURI(event.target[4].value)
        app.navigate "/route/?from=#{from}&to=#{to}&time=#{time}&timetype=#{timetype}", true

    centerMapByFocusedInput: (event) ->
        # ToDo: Too slow... should use the values from @currentFromLocation and @currentToLocation
        # Not done so at the moment due to the different coordinate systems; how to transform to LonLat?
        Reittiopas.locate event.currentTarget.value, (data) =>
            pos = data.coords.split(",")
            centerMap toSMercator({lon:pos[0], lat:pos[1]})

    updateFrom: (event) ->
        @updatePosition event.currentTarget.value, "#from", @currentFromLocation
        return undefined

    updateTo: (event) ->
        console.log "moi"
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

#            targetDragVector.move sm_coords
            console.log sm_coords
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
        sytle =
            fillColor: "#ee0000"
            fillOpacity: 0.4
            strokeColor: "#ff0000"
            pointRadius: 6

        dragpoint = new OpenLayers.Feature.Vector(geometryPoint, null, sytle)
        app.vectors.addFeatures [ dragpoint ]
        drag = new OpenLayers.Control.DragFeature app.vectors,
            autoActivate: true
            onComplete: (event) =>
                sm_coords =
                    lon: event.geometry.x
                    lat: event.geometry.y
                Reittiopas.reverseLocate toWGS(sm_coords), (data) =>
                    $(targetTextBox).val data.name
        
        app.map.addControl drag
        drag.activate()
        return dragpoint

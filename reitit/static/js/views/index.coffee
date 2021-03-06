window.IndexView = Backbone.View.extend

    initialize: ->
        @template = _.template tpl.get('searcher')
        res = (event) =>
            @resizeMap(event)
        $(window).on "resize", res

    initMap: ->
        app.map.render $("#basicMap")[0]
        
    resizeMap: (event) ->
        unless @neededSpace
            @neededSpace = $(@el).find(".header h1").height() + $(@el).find(".content").height() + 55
        h = Math.max($(window).height() - @neededSpace, 120)
        $("#basicMap").height(h + "px")
        app.map.updateSize()

    updateLocationFields: (data) ->
        return undefined unless data
        @updateFrom currentTarget: value: data.from if data.from
        @updateTo currentTarget: value: data.to if data.to
        return undefined

#        event = currentTarget: value: undefined
#        if window.InputView::from != undefined
#            event.currentTarget.value = window.InputView::from
#            @updateFrom event         
#        else if window.InputView::to != undefined
#            event.currentTarget.value = window.InputView::to
 #           @updateTo event
#        window.InputView::from = undefined
#        window.InputView::to = undefined

    events:
        "submit": "submit"
        "change #from": "updateFrom"
        "change #to": "updateTo"
        "focus #from": "onFocusedFrom"
        "focus #to": "onFocusedTo"
        "click #from": "onFocusedFrom"
        "click #to": "onFocusedTo"
        "click #fromFocus": "onCenterFrom"
        "click #toFocus": "onCenterTo"

    render: ->
        d = new Date()
        time =
            hours: d.getHours()
            minutes: d.getMinutes()

        if time.hours < 10
            time.hours = "0" + time.hours
        if time.minutes < 10
            time.minutes = "0" + time.minutes


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
        
        nav = "/route/?from=#{from}&to=#{to}&time=#{time}"
        if timetype == "arrival"
            nav += "&timetype=#{timetype}"
        app.navigate nav
        app.results(true)

    onFocusedFrom: (event) ->
        event.preventDefault()
#        window.InputView::from = event.currentTarget.value
        app.navigate "/input/?target=from&value=#{event.currentTarget.value}", true

    onFocusedTo: (event) ->
        event.preventDefault()
#        window.InputView::to = event.currentTarget.value
        app.navigate "/input/?target=to&value=#{event.currentTarget.value}", true
        
    onCenterFrom: (event) ->
        coords = new OpenLayers.LonLat @currentFromLocation.geometry.x, @currentFromLocation.geometry.y
        centerMap coords

    onCenterTo: (event) ->
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

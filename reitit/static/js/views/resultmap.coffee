window.ResultMapView = Backbone.View.extend

    initialize: ->
        @template = _.template tpl.get('resultmap')
        res = (event) =>
            @resizeMap(event)
        $(window).on "resize", res

    initMap: ->
        app.map.render $("#resultMap")[0]
        
    resizeMap: (event) ->
        unless @neededSpace
            @neededSpace = $(@el).find(".header h1").height() + $(@el).find(".content").height() + 55
        h = Math.max($(window).height() - @neededSpace, 120)
        $("#resultMap").height(h + "px")
        app.map.updateSize()



    events:
        "click .back": "back"

    render: ->
        $(@el).html @template()
        @showOnMap()


    showOnMap: ->
        #        event.preventDefault()
        #model = @model[parseInt(event.currentTarget.getAttribute("data-index"))][0]
        app.route.removeAllFeatures()
        _.each @model.legs, (leg) =>
            points = []
            if leg.shape
                _.each leg.shape, (coord) ->
                    wgs_coords =
                        lon: coord.x
                        lat: coord.y
                    sm_coords = toSMercator(wgs_coords)
                    centerMap(sm_coords, 12)
                    points.push new OpenLayers.Geometry.Point(sm_coords.lon, sm_coords.lat)
            else
                _.each leg.locs, (loc) ->
                    #console.log loc
                    wgs_coords =
                        lon: loc.coord.x
                        lat: loc.coord.y
                    sm_coords = toSMercator(wgs_coords)
                    centerMap(sm_coords, 12)
                    points.push new OpenLayers.Geometry.Point(sm_coords.lon, sm_coords.lat)
                
        
            line = new OpenLayers.Geometry.LineString(points)

            style =
                strokeOpacity: 0.5
                strokeWidth: 5

            if leg.type == "bus"
                style["strokeColor"] = "#0000ff"
            else if leg.type == "tram"
                style["strokeColor"] = "#00ff00"
            else if leg.type == "train"
                style["strokeColor"] = "#ff0000"
            else if leg.type == "metro"
                style["strokeColor"] = "#ff8c00"

            app.route.addFeatures [new OpenLayers.Feature.Vector(line, null, style)]


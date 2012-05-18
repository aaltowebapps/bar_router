window.ResultMapView = Backbone.View.extend

    initialize: ->
        @template = _.template tpl.get('resultmap')

    initMap: ->
        app.map.render $("#resultMap")[0]
        #TODO remove this on view close
        $(window).on "resize", @resizeMap
        @resizeMap()
        
    resizeMap: ->
        h = $(window).height() - $("#header h1").height() - $("#content").height() - 55
        h = Math.max(h, 120)
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

            if ["1","3","4","5"].indexOf(leg.type) != -1 #bus
                style["strokeColor"] = "#0000ff"
            else if leg.type == "2" #tram
                style["strokeColor"] = "#00ff00"
            else if leg.type == "12" #train
                style["strokeColor"] = "#ff0000"
            else if leg.type == "6" #metro
                style["strokeColor"] = "#ff8c00"

            app.route.addFeatures [new OpenLayers.Feature.Vector(line, null, style)]


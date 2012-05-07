window.ResultsView = Backbone.View.extend
    el: $("#content")

    initialize: ->
        @template = _.template tpl.get('result')
        @params =
            from: getUrlParam("from")
            to: getUrlParam("to")

        time = getUrlParam("time")
        timetype = getUrlParam("timetype")
        @params.time = time if time
        @params.timetype = timetype if timetype
        
        @model = undefined

        unless app.located
            Reittiopas.locate @from, (data) ->
                pos = data.coords.split(",")
                centerMap(pos[0], pos[1])


    events:
        "click .route a": "showOnMap"

    render: ->
        $("#loader").show()
        #$("#basicMap").hide()
        $(@el).html ""

        Reittiopas.route @params, (results) =>
            @model = results
            _.each results, (result, index) =>
                $(@el).append(@template({route: result[0], index: index}))

            $("#loader").hide()

        return @

    #these should be bound as anon functions as the elements are created
    showOnMap: (event) ->
        event.preventDefault()
        model = @model[parseInt(event.currentTarget.getAttribute("data-index"))][0]
        app.vectors.removeAllFeatures()
        _.each model.legs, (leg) =>
            points = []
            _.each leg.locs, (loc) ->
                #console.log loc
                point = new OpenLayers.LonLat(loc.coord.x, loc.coord.y)
                    .transform(app.wgs84, app.s_mercator)
                points.push new OpenLayers.Geometry.Point(point.lon, point.lat)
        
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

            app.vectors.addFeatures [new OpenLayers.Feature.Vector(line, null, style)]

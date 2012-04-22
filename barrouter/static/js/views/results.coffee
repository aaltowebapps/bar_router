window.ResultsView = Backbone.View.extend
    el: $("#content")

    initialize: ->
        @template = _.template tpl.get('result')
        @from = getUrlParam("from")
        @to = getUrlParam("to")


    asdf: ->
        #this is here as a reminder
        Reittiopas.route @from, @to, (data) =>
            @vectors.removeAllFeatures()
            _.each data.legs, (leg) =>
                console.log leg
                points = []
                _.each leg.locs, (point) ->
                    loc = new OpenLayers.LonLat(point.coord.x, point.coord.y)
                        .transform(app.wgs84, app.s_mercator)
                    points.push new OpenLayers.Geometry.Point(loc.lon, loc.lat)
            
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

                @vectors.addFeatures [new OpenLayers.Feature.Vector(line, null, style)]

    events:
        "click #dummy": "render"

    render: ->
        $("#loader").show()
        $("#basicMap").hide()
        $(@el).html ""

        Reittiopas.route @from, @to, (results) =>
            console.log results
            _.each results, (result) =>
                console.log result
                $(@el).append(@template(route: result[0]))

            $("#loader").hide()

        return @

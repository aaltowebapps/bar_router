window.ResultMapView = Backbone.View.extend
    el: $("#content")

    initialize: (data) ->
        @template = _.template tpl.get('resultMap')

    events:
        "click #back": "back"

    render: ->
        $(@el).html @template()
        $("#basicMap")
            .show()
            .css({height: "90%"})
        

        app.vectors.removeAllFeatures()
        _.each @model.legs, (leg) =>
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

        return @
    
    back: (event) ->
        event.preventDefault()

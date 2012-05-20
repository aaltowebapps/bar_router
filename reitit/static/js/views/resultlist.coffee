window.ResultsView = Backbone.View.extend
    
    initialize: ->
        @template = _.template tpl.get('results')

    events:
        "click .back": "back"


    render: ->
        $(@el).html @template()
        unless @model
            @updateModel()
        else
            @generateList()

        return @
   
    updateParams: ->
        @params =
            from: getUrlParam("from")
            to: getUrlParam("to")

        time = getUrlParam("time")
        timetype = getUrlParam("timetype")
        @params.time = time if time
        @params.timetype = timetype if timetype


    updateModel: ->
        $(@el).find("#routelist").html ""
        $(@el).find("#loader").css("display", "block")
        @updateParams()
        Reittiopas.route @params, (results) =>
            @model = @processRoutes(results)
            $(@el).find("#loader").hide()
            @generateList()

    generateList: ->
        routelist = $(@el).find("#routelist")
        _.each @model, (route) =>
            item = new ResultsViewItem(model: route).render().el
            routelist.append item
        routelist.listview('refresh')


    processRoutes: (routes) ->
        output = []
        _.each routes, (route) ->
            route = route[0]
            legs = []
            _.each route.legs, (leg) ->
                if leg.type == "walk"
                    leg.type = "walk"
                    leg.code = null
                else if ["1", "3", "4", "5"].indexOf(leg.type) != -1
                    leg.type = "bus"
                    leg.code = $.trim(leg.code.slice(1,5))
                    if leg.code[0] == "0"
                        leg.code = leg.code.slice(1)
                else if leg.type == "2"
                    out.type = "tram"
                    leg.code = $.trim(leg.code.slice(2,5))
                    if leg.code[0] == "0"
                        leg.code = leg.code.slice(1)
                else if leg.type == "12"
                    out.type = "train"
                    leg.code = $.trim(leg.code.slice(3,5))
                else if leg.type = "6"
                    out.type = "metro"
                    leg.code = "Metro"


                locs = []
                _.each leg.locs, (loc) ->
                    loc.arrTime = loc.arrTime.slice(8,10) + ":" + loc.arrTime.slice(10,12)
                    loc.depTime = loc.depTime.slice(8,10) + ":" + loc.depTime.slice(10,12)
                    locs.push(loc)
                leg.locs = locs


                legs.push(leg)
            route.legs = legs
            output.push(route)
        return output


window.ResultsViewItem = Backbone.View.extend
    tagName: "li"

    events:
        "click a":"showRoute"

    showRoute: ->
        app.navigate("#showRoute")
        app.resultMap(@model)

    initialize: ->
       @template = _.template tpl.get('result-item')

    render: ->
        $(@el).html @template(route: @model)
        return @

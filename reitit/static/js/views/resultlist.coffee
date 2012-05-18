window.ResultsView = Backbone.View.extend
    
    initialize: ->
        @template = _.template tpl.get('results')
        @params =
            from: getUrlParam("from")
            to: getUrlParam("to")

        time = getUrlParam("time")
        timetype = getUrlParam("timetype")
        @params.time = time if time
        @params.timetype = timetype if timetype

    events:
        "click .back": "back"

    beforeClose: ->
        window.ResultsView::model = @model

    render: ->
        $(@el).html @template()

        unless @model
            $(@el).find("#loader").css("display", "block")
            Reittiopas.route @params, (results) =>
                @model = results
                $(@el).find("#loader").hide()
                @generateList()
        else
            @generateList()

        return @

    generateList: ->
        routelist = $(@el).find("#routelist")
        _.each @model, (result) =>
            item = new ResultsViewItem(model: result[0]).render().el
            routelist.append item
        routelist.listview('refresh')

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

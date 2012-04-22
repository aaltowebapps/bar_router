window.ResultsView = Backbone.View.extend
    el: $("#content")

    initialize: ->
        @template = _.template tpl.get('result')
        @from = getUrlParam("from")
        @to = getUrlParam("to")
        @model = undefined


    events:
        "click .route a": "showOnMap"

    render: ->
        $("#loader").show()
        $("#basicMap").hide()
        $(@el).html ""

        Reittiopas.route @from, @to, (results) =>
            @model = results
            #console.log results
            _.each results, (result) =>
                #console.log result
                $(@el).append(@template(route: result[0]))

            $("#loader").hide()

        return @

    #these should be bound as anon functions as the elements are created
    showOnMap: (event) ->
        event.preventDefault()
        app.resultmap(@model[0][0])

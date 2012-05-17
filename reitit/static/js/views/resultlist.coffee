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
        @model = undefined


    render: ->
        $(@el).html @template()
        console.log($(@el).find("#routelist"))
        Reittiopas.route @params, (results) =>
            @model = results
            _.each results, (result, index) =>
                item = new ResultsViewItem({model: result[0], index: index}).render().el
                $(@el).find("#routelist").append item
            
            $(@el).find("#routelist").listview('refresh')

        return @


window.ResultsViewItem = Backbone.View.extend
    tagName: "li"

    events:
        "click a":"ping"

    ping: ->
        console.log @model

    initialize: ->
       @template = _.template tpl.get('result-item')

    render: ->
        $(@el).html @template({route:@model, index:@options.index})
        return @

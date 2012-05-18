window.InputView = Backbone.View.extend
    events:
        "submit": "submit"
        "click #inputFav": "toggleFavState"

    initialize: ->
        @template = _.template tpl.get('input')
        @favorites = new Favorites()
        @favorites.bind('add', @addOne, @)
        @favorites.bind('reset', @addAll, @)
        
    render: ->
        @value = getUrlParam("value")
        $(@el).html @template({ currentInput:@value })
        @favlist = $(@el).find("#favlist")
        @favorites.fetch()
        @addAll()   
        return @
    
    submit: (event) ->
        event.preventDefault()
        return undefined
        
    addOne: (item) ->
        address = item.get "address"
        if address != undefined and address != ""
            item = new FavoriteItemView({model: item}).render().el
            console.debug "Adding one..."
            console.debug $("#favlist")
            $("#favlist").append item
            $("#favlist").listview("refresh")
            
        return undefined
        
    addAll: () ->
        _.each @favorites.models, (result, index) =>
            item = new FavoriteItemView({model: result}).render().el
            @favlist.append item
            
        try
            @favlist.listview("refresh")
        catch error
            # Gets called before view is actually rendered...
            console.debug error
            
        return undefined
        
    toggleFavState: (event) ->
        el = event.currentTarget
        enabled = el.src.indexOf("off") != -1
        if enabled then el.src = el.src.replace("off", "on")
        else el.src = el.src.replace("on", "off")
        
        address = $("#input")[0].value
        if enabled then @favorites.create {address: address}
        else @favorites.each((item) -> item.destroy)
        return undefined
        

window.FavoriteItemView = Backbone.View.extend
    tagname: "li"

    initialize: ->
        @model.bind('change', @render, @)
        @template = _.template tpl.get('favorite-item')
       
    render: ->
        $(@el).html @template({address:@model.get("address"), index:@options.index})
        return @
    
    clear: ->
        @model.destroy()

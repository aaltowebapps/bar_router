window.InputView = Backbone.View.extend
    events:
        "submit": "submit"
        "change #input": "onInputChanged"
        "click #favicon": "onFavIconClick"
        "click .favitem": "onFavItemClick"

    initialize: ->
        @template = _.template tpl.get('input')
        @favorites = new Favorites()
        @favorites.bind('add', @addOne, @)
        @favorites.bind('remove', @removeOne, @)
        @favorites.bind('reset', @addAll, @)
        
    render: ->
        inputValue = getUrlParam("value")
        $(@el).html @template({ currentInput:inputValue })
        @favlist = $(@el).find("#favlist")
        @favorites.fetch()
        @onInputChanged(null)
        return @
    
    submit: (event) ->
        event.preventDefault()
        return undefined
        
    addOne: (item) ->
        address = item.get "address"
        if address != undefined and address != ""
            item = new FavoriteItemView({model: item}).render().el
            $(@el).find("#favlist").append item
            @refreshListView()
            
        return undefined
    
    addAll: () ->
        _.each @favorites.models, (item, index) =>
            @addOne(item)     
        return undefined
    
    removeOne: (item) ->
        # Should remove only single elements...
        @favlist.empty()
        @addAll()
        
    onInputChanged: (event) ->
        inputValue = $(@el).find("#input")[0].value
        favIcon = $(@el).find("#favicon")[0]
        matches = @favorites.byAddress inputValue
        if matches.length > 0
            favIcon.src = favIcon.src.replace("off", "on")
        else
            favIcon.src = favIcon.src.replace("on", "off")
        
    onFavIconClick: (event) ->
        el = $(@el).find("#favicon")[0]
        
        enabled = el.src.indexOf("off") != -1
        if enabled then el.src = el.src.replace("off", "on")
        else el.src = el.src.replace("on", "off")
        
        address = $("#input")[0].value
        if enabled
            unless @favorites.contains {address:address}
                fav = @favorites.create {address:address}
        else
            _.each @favorites.byAddress(address), (fav) -> fav.destroy()
        
        return undefined
    
    onFavItemClick: (event) ->
        $(@el).find("#input")[0].value = event.currentTarget.innerHTML
    
    refreshListView: ->
        try
            @favlist.listview("refresh")
        catch error
            # Gets called before view is actually rendered...
            console.debug error


window.FavoriteItemView = Backbone.View.extend
    tagname: "li"

    initialize: ->
        @model.bind('change', @render, @)
        @template = _.template tpl.get('favorite-item')
       
    render: ->
        $(@el).html @template({address:@model.get("address"), index:@options.index})
        return @

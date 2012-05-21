window.InputView = Backbone.View.extend
    transition: "pop"

    events:
        "click .back": "back"
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
        @updateParams()
#        inputValue = window.InputView::[@target]
        $(@el).html @template({ currentInput:@value })
        @favlist = $(@el).find("#favlist")
        @onInputChanged(null)
        return @

    updateParams: ->
        @target = getUrlParam("target")
        @value = getUrlParam("value")
        $(@el).find("#input").val @value
        

    updateListview: ->
        @favorites.fetch()
        @onInputChanged()
    
    submit: (event) ->
        event.preventDefault()
#        window.InputView::[@target] = $(@el).find("#input")[0].value
#        @back(event)
        app.transition = @transition
        app.historyBack = true
        app.navigate "/"
        call = {}
        call["#{@target}"] = $(@el).find("#input")[0].value
        app.index call
        return undefined
        
    addOne: (item) ->
        address = item.get "address"
        if address != undefined and address != ""
            item = new FavoriteItemView({model: item}).render().el
            @favlist.append item # Why does jQuery not style the appended item?
            @refreshListView()
            
        return undefined
    
    addAll: () ->
        @favlist.empty()
        _.each @favorites.models, (item, index) =>
            @addOne(item)     
        return undefined
    
    removeOne: (item) ->
        # Should remove only single elements...
        @favlist.empty()
        @addAll()
        
    onInputChanged: (event) ->
        #window.InputView::[@target] = $(@el).find("#input")[0].value
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
        console.log address
        if enabled
            Reittiopas.locate address, (data) =>
                if data.details.houseNumber
                    val = "#{data.name} #{data.details.houseNumber}, #{data.city}"
                else
                    val = "#{data.name}, #{data.city}"
                $("#input").val val
                unless @favorites.contains {address:val}
                    fav = @favorites.create {address:val}
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
        @template = _.template tpl.get('favorite-item')
       
    render: ->
        $(@el).html @template({address:@model.get("address"), index:@options.index})
        return @

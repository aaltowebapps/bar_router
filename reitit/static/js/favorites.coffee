class Favorite extends Backbone.Model
    defaults:
        address: ''
        
    initialize: ->
        unless @get 'content'
            @set {"content": @defaults.content}
 
class Favorites extends Backbone.Collection
    model: Favorite
    localStorage: new Store 'favoritesdb'
    
    clear: ->
        _.each @models.slice(0) (item) -> item.destroy()
        
    contains: (item) ->
        return @byAddress(item.address).length != 0
        
    byAddress: (address) ->
        return _.filter @models, (fav) -> fav.get("address") == address
        
    comparator: (item) ->
        return item.get "address"

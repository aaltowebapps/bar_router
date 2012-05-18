#http://documentcloud.github.com/backbone/docs/todos.html

class Favorite extends Backbone.Model
    defaults:
        address: ''
 
class Favorites extends Backbone.Collection
    model: Favorite
    localStorage: new Store('favoritesdb')
    contains: (item) ->
        return @indexOf(item) != -1

// Generated by CoffeeScript 1.3.1
var Favorite, Favorites,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Favorite = (function(_super) {

  __extends(Favorite, _super);

  Favorite.name = 'Favorite';

  function Favorite() {
    return Favorite.__super__.constructor.apply(this, arguments);
  }

  Favorite.prototype.defaults = {
    address: ''
  };

  Favorite.prototype.initialize = function() {
    if (!this.get('content')) {
      return this.set({
        "content": this.defaults.content
      });
    }
  };

  return Favorite;

})(Backbone.Model);

Favorites = (function(_super) {

  __extends(Favorites, _super);

  Favorites.name = 'Favorites';

  function Favorites() {
    return Favorites.__super__.constructor.apply(this, arguments);
  }

  Favorites.prototype.model = Favorite;

  Favorites.prototype.localStorage = new Store('favoritesdb');

  Favorites.prototype.clear = function() {
    return _.each(this.models.slice(0)(function(item) {
      return item.destroy();
    }));
  };

  Favorites.prototype.contains = function(item) {
    return this.byAddress(item.address).length !== 0;
  };

  Favorites.prototype.byAddress = function(address) {
    return _.filter(this.models, function(fav) {
      return fav.get("address") === address;
    });
  };

  Favorites.prototype.comparator = function(item) {
    return item.get("address");
  };

  return Favorites;

})(Backbone.Collection);

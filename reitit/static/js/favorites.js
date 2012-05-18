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

  Favorites.prototype.contains = function(item) {
    return this.indexOf(item) !== -1;
  };

  return Favorites;

})(Backbone.Collection);

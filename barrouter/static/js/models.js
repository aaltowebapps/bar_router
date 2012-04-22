
window.Route = Backbone.Model.extend({
  urlRoot: "/api/query/"
});

window.Routes = Backbone.Collection.extend({
  model: Route,
  url: "/api/query/"
});

window.Face = Backbone.Model.extend
    urlRoot: "/api/faces/"

window.FaceCollection = Backbone.Collection.extend
    model: Face
    url: "/api/faces/"

window.Feedback = Backbone.Model.extend
    urlRoot:"/api/feedback/"

window.SearchCollection = Backbone.Collection.extend
    model: Face
    url: "/api/search/"

window.Tag = Backbone.Model.extend
    urlRoot: "/api/tags/"

window.TagCollection = Backbone.Collection.extend
    model: Tag
    url: "/api/tags/"

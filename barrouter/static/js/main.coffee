app = undefined

Backbone.View::close = ->
  console.log "Closing view " + this
  @beforeClose()  if @beforeClose
#  @remove()
  @undelegateEvents()

Backbone.View::navigateAnchor = (event) ->
    event.preventDefault()
    app.navigate(event.currentTarget.getAttribute("href"), {trigger: true})

AppRouter = Backbone.Router.extend
  initialize: ->
    @wgs84 = new OpenLayers.Projection("EPSG:4326")
    @s_mercator = new OpenLayers.Projection("EPSG:900913")

  routes:
    "": "index"

  index: ->
    @before =>
      return new IndexView().render()

  before: (callback) ->
    @currentPage.close() if @currentPage
    @currentPage = callback()


tpl.loadTemplates [ "index" ], ->
  routes = AppRouter::routes
  for route, action of routes
      routes[route + "/"] = action
  AppRouter::routes = routes
  app = new AppRouter()

  Backbone.history.start()

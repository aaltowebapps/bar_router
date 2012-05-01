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
    @map = new OpenLayers.Map("basicMap")
    mapnik = new OpenLayers.Layer.OSM()
    @vectors = new OpenLayers.Layer.Vector("Vector layer")
    @map.addLayer mapnik
    @map.addLayer @vectors
    @map.addControl new OpenLayers.Control.DrawFeature(@vectors, OpenLayers.Handler.Path)

    @located = false

    # CSS is stuffed in the main app.js built during deployment
    unless debug
      $("head").append "<style type='text/css'>" + collated_stylesheets + "</style>"



  routes:
    "": "index"
    "route/*splat": "results"

  index: ->
    @before =>
      return new IndexView().render()

  results: ->
    @before =>
      return new ResultsView().render()

  resultmap: (model) ->
    @before =>
      return new ResultMapView(model: model).render()

  before: (callback) ->
    @currentPage.close() if @currentPage
    @currentPage = callback()


tpl.loadTemplates [ "index", "result" ], ->
  routes = AppRouter::routes
  for route, action of routes
      routes[route + "/"] = action
  AppRouter::routes = routes
  app = new AppRouter()

  Backbone.history.start()

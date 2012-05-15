app = undefined

Backbone.View::navigateAnchor = (event) ->
    event.preventDefault()
    app.navigate(event.currentTarget.getAttribute("href"), {trigger: true})

AppRouter = Backbone.Router.extend
    initialize: ->
        @wgs84 = new OpenLayers.Projection("EPSG:4326")
        @s_mercator = new OpenLayers.Projection("EPSG:900913")
        @map = new OpenLayers.Map
            theme: null
            controls: [
                new OpenLayers.Control.Attribution(),
                new OpenLayers.Control.TouchNavigation
                    dragPanOptions: {enableKinetcs: true }
                new OpenLayers.Control.Zoom()
            ]
            layers: [
                new OpenLayers.Layer.OSM("OpenStreetMap", null, {transitionEffect: 'resize'})
            ]
            center: new OpenLayers.LonLat(742000, 5861000)
            zoom: 14


                

#        @map = new OpenLayers.Map("basicMap")
#        mapnik = new OpenLayers.Layer.OSM()
#        @vectors = new OpenLayers.Layer.Vector("Vector layer")
#        @map.addLayer mapnik
#        @map.addLayer @vectors
#        @map.addControl new OpenLayers.Control.DrawFeature(@vectors, OpenLayers.Handler.Path)


        @located = false
  
        # CSS is stuffed in the main app.js built during deployment
        unless debug
            $("head").append "<style type='text/css'>" + collated_stylesheets + "</style>"
        
        $(".back").on "click", (event) ->
            window.history.back()
            return false

        @firstPage = true

    routes:
        "": "index"
        "route/*splat": "results"

    index: ->
        @changePage(new IndexView())

    results: ->
        @changePage(new ResultsView())

#    resultmap: (model) ->
#        @changePage(new ResultMapView(model: model))

    changePage: (page) ->
        $(page.el).attr "data-role", "page"
        page.render()
        $("body").append $(page.el)
        transition = $.mobile.defaultPageTransition
        if @firstPage
            transition = "none"
            @firstPage = false

        $.mobile.changePage $(page.el),
            changeHash: false
            transition: transition
        
        page.initMap() if page.initMap


tpl.loadTemplates [ "searcher", "result" ], ->
    routes = AppRouter::routes
    for route, action of routes
        routes[route + "/"] = action
    AppRouter::routes = routes
    app = new AppRouter()

    Backbone.history.start()

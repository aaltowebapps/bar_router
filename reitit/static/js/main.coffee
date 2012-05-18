app = undefined

Backbone.View::navigateAnchor = (event) ->
    event.preventDefault()
    app.navigate(event.currentTarget.getAttribute("href"), {trigger: true})

AppRouter = Backbone.Router.extend
    initialize: ->
        @wgs84 = new OpenLayers.Projection("EPSG:4326")
        @s_mercator = new OpenLayers.Projection("EPSG:900913")
        @vectors = new OpenLayers.Layer.Vector("Vector layer")
        drag = new OpenLayers.Control.DragFeature @vectors,
            autoActivate: true
            onComplete: (event) ->
                sm_coords =
                    lon: event.geometry.x
                    lat: event.geometry.y
                Reittiopas.reverseLocate toWGS(sm_coords), (data) ->
                    $(event.id).val data.name
                    
        @map = new OpenLayers.Map
            theme: null
            controls: [
                drag
                new OpenLayers.Control.Attribution()
                new OpenLayers.Control.TouchNavigation
                    dragPanOptions: {enableKinetcs: true }
                new OpenLayers.Control.Zoom()
                new OpenLayers.Control.DrawFeature(@vectors, OpenLayers.Handler.Path)
            ]
            layers: [
                new OpenLayers.Layer.OSM("OpenStreetMap", null, {transitionEffect: 'resize'})
                @vectors
            ]
            center: new OpenLayers.LonLat(742000, 5861000)
            zoom: 14

        drag.activate()

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
        "input/*splat": "input"

    index: ->
        @changePage(new IndexView())

    results: ->
        @changePage(new ResultsView())
        
    input: ->
        @changePage(new InputView())

#    resultmap: (model) ->
#        @changePage(new ResultMapView(model: model))

    changePage: (page) ->
        $(page.el).attr "data-role", "page"
        page.render()
        $("body").append $(page.el)
#        transition = $.mobile.defaultPageTransition
        transition = "slide"
        if @firstPage
            transition = "none"
            @firstPage = false

        console.log transition
        $.mobile.changePage $(page.el),
            changeHash: false
            transition: transition
        
        page.initMap() if page.initMap

tpl.loadTemplates [ "searcher", "results", "result-item", "input", "favorite-item" ], ->
    routes = AppRouter::routes
    for route, action of routes
        routes[route + "/"] = action
    AppRouter::routes = routes
    app = new AppRouter()

    Backbone.history.start()

app = undefined

Backbone.View::navigateAnchor = (event) ->
    event.preventDefault()
    app.navigate(event.currentTarget.getAttribute("href"), {trigger: true})


Backbone.View::back = (event) ->
    app.route.removeAllFeatures()
    event.preventDefault()
    if @transition
        app.transition = @transition
    else
        app.transition = "slide"
    app.historyBack = true
    window.history.back()

AppRouter = Backbone.Router.extend
    initialize: ->
        @wgs84 = new OpenLayers.Projection("EPSG:4326")
        @s_mercator = new OpenLayers.Projection("EPSG:900913")
        @vectors = new OpenLayers.Layer.Vector("Vector layer")
        @route = new OpenLayers.Layer.Vector("Route layer")
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
                new OpenLayers.Control.DrawFeature(@route, OpenLayers.Handler.Path)
            ]
            layers: [
                new OpenLayers.Layer.OSM("OpenStreetMap", null, {transitionEffect: 'resize'})
                @route
                @vectors
            ]
            center: new OpenLayers.LonLat(742000, 5861000)
            zoom: 14

        drag.activate()

        @located = false
        @currentPage = null
  
        # CSS is stuffed in the main app.js built during deployment
        unless debug
            $("head").append "<style type='text/css'>" + collated_stylesheets + "</style>"
        
        @historyBack = false
        @firstPage = true
        @pages = {}
        @transition = "slide"

    routes:
        "": "index"
        "route/*splat": "results"
        "input/*splat": "input"

    index: (data) ->
        unless @pages.index
            @pages.index = new IndexView()
            @insertToDOM @pages.index
        @pages.index.updateLocationFields(data) if data
        @changePage @pages.index

    results: (update) ->
        unless @pages.resultsView
            @pages.resultsView = new ResultsView()
            @insertToDOM @pages.resultsView
        else if update == true
            @pages.resultsView.updateModel()
        @changePage @pages.resultsView
        
    input: () ->
        unless @pages.favoritesView
            @pages.favoritesView = new InputView()
            @insertToDOM @pages.favoritesView
        else
            @pages.favoritesView.updateParams()
        @changePage @pages.favoritesView

    resultMap: (model) ->
        unless @pages.resultMap
            @pages.resultMap = new ResultMapView(model: model)
            @insertToDOM @pages.resultMap
        else
            @pages.resultMap.model = model
            @pages.resultMap.showOnMap()
        @changePage @pages.resultMap

    insertToDOM: (page) ->
        $(page.el).attr "data-role", "page"
        page.render()
        $("body").append $(page.el)

    changePage: (page) ->
        transition = app.transition
        transition = page.transition if page.transition

        if @firstPage or $.browser.opera
            transition = "none"
            @firstPage = false

        animate =
            changeHash:false
            transition:transition

        if @historyBack
            @historyBack = false
            animate.reverse = true

        app.transition = "slide"

        $.mobile.changePage $(page.el), animate
            
        page.updateListview() if page.updateListview
        page.initMap() if page.initMap
        page.resizeMap() if page.resizeMap
        page.updateLocationFields() if page.updateLocationFields

$ ->
    tpl.loadTemplates [ "searcher", "results", "result-item", "input", "favorite-item", "resultmap" ], ->
        routes = AppRouter::routes
        for route, action of routes
            routes[route + "/"] = action
        AppRouter::routes = routes
        app = new AppRouter()

        Backbone.history.start()


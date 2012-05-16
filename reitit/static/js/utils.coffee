tpl =
  # Hash of preloaded templates for the app
  templates: {}
  
  # Recursively pre-load all the templates for the app.
  # This implementation should be changed in a production environment. All the template files should be
  # concatenated in a single file.
  
  loadTemplates: (names, callback) ->
    unless debug
      callback()
      return

    loadTemplate = (index) =>
      name = names[index]
    #  console.log "Loading template: " + name
      $.get static_prefix + "templates/" + name + ".html", (data) =>
        @templates[name] = data
        index++
        if index < names.length
          loadTemplate index
        else
          callback()

    loadTemplate 0

  # Get template by name from hash of preloaded templates
  get: (name) ->
    @templates[name]


getUrlParam = (name) ->
    results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href)
    return undefined unless results
    return decodeURI(results[1])


centerMap = (coords) ->
    # Eats s_mercator coordinates
    app.map.setCenter coords, 14
    app.located = true

toSMercator = (coords) ->
    return new OpenLayers.LonLat(coords.lon, coords.lat).transform(app.wgs84, app.s_mercator)

toWGS = (coords) ->
    return new OpenLayers.LonLat(coords.lon, coords.lat).transform(app.s_mercator, app.wgs84)

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

printStack = () ->
    try
      printStackExceptionTrigger += 10
    catch error
      console.debug(error.stack)

getUrlParam = (name) ->
    results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href)
    return undefined unless results
    return decodeURI(results[1])


centerMap = (x, y) ->
    center = new OpenLayers.LonLat(x, y).transform(app.wgs84, app.s_mercator)
    app.map.setCenter center, 15
    app.located = true

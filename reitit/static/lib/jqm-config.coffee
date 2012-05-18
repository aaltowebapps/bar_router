$(document).bind "mobileinit", ->
    #    console.log "mobileinit"
    $.mobile.ajaxEnabled = false
    $.mobile.linkBindingEnabled = false
    $.mobile.hashListeningEnabled = false
    $.mobile.pushStateEnabled = false

    $("div[data-role=\"page\"]").on "pagehide", (event, ui) ->
        $(event.currentTarget).remove()

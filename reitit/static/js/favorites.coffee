Favorites =
    add: (address) ->
        favLocations = @getFavoriteLocations()
        if favLocations.indexOf(address) == -1
            favLocations.push address
            @setFavoriteLocations(favLocations)
        return undefined

    remove: (address) ->
        favLocations = @getFavoriteLocations()
        index = favLocations.indexOf(address)
        if index != -1
            favLocations.splice index 1
            @setFavoriteLocations(favLocations)
        return undefined

    getFavoriteLocations: () ->
        result = new Array()
        store = window.localStorage
        if store != null
            flatList = store.getItem("favLocations")
            if flatList != null
                result = flatList.split(" /||/ ")
        return result.clean("")

    setFavoriteLocations: (locationArray) ->
        if locationArray != null and locationArray.length != 0
            flatList = locationArray.join(" /||/ ")
            store = window.localStorage
            if store != null
                store.setItem("favLocations", flatList)
        return undefined

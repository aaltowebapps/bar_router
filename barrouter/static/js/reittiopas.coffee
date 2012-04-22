Reittiopas =
    locate: (key, callback) ->
        $.ajax
            method: "GET"
            url: "/api/query"
            data:
                key: key
                request: "geocode"
            success: (data) ->
                callback(data[0])
        

    reverseLocate: (x, y, callback) ->
        pos = new OpenLayers.LonLat(x, y)
            .transform(app.s_mercator, app.wgs84)

        $.ajax
            method: "GET"
            url: "/api/query/"
            data:
                coordinate: "#{pos.lon},#{pos.lat}"
                request: "reverse_geocode"
            success: (data) ->
                callback(data[0])
                #console.log "http://api.reittiopas.fi/hsl/prod/?user=aaltoreittiopas&pass=m33p1qRA&request=reverse_geocode&coordinate=" + pos.lon + "," + pos.lat + "&epsg_out=wgs84&epsg_in=wgs84"


    route: (from, to, callback) ->
        $.ajax
            method: "GET"
            url: "/api/query/"
            data:
                request: "route"
                from: from
                to: to
            success: (data) ->
                callback(data)

        #routes = new Routes()
        #routes.fetch
        #    data:
        #       request: "route"
        #        from: from
        #        to: to
        #    success: (data) ->
        #        console.log data
        #        callback(routes)
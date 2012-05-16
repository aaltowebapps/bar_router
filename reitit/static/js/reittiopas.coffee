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
        

    reverseLocate: (coords, callback) ->
        $.ajax
            method: "GET"
            url: "/api/query/"
            data:
                coordinate: "#{coords.lon},#{coords.lat}"
                request: "reverse_geocode"
            success: (data) ->
                console.log data
                callback(data[0])
                #console.log "http://api.reittiopas.fi/hsl/prod/?user=aaltoreittiopas&pass=m33p1qRA&request=reverse_geocode&coordinate=" + pos.lon + "," + pos.lat + "&epsg_out=wgs84&epsg_in=wgs84"


    route: (data, callback) ->
        data.request = "route"
        $.ajax
            method: "GET"
            url: "/api/query/"
            data: data
            success: (data) ->
                callback(data)

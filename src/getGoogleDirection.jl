function getGoogleDirection(origin::Tuple{Float64,Float64},
                            destination::Tuple{Float64,Float64},
                            deptime::Int64,
                            key::String)

    ostr = "origin=$(origin[1]),$(origin[2])"
    dstr = "destination=$(destination[1]),$(destination[2])"
    qstr = "$ostr&$dstr&travel_mode=driving&units=metric&key=$key"
    url = "https://maps.googleapis.com/maps/api/directions/json?$qstr"

    r = HTTP.request("GET", url)
    data = Nothing
    if r.status == 200
        data = String(r.body)
        data = JSON.Parser.parse(data)
    end
    return data
end

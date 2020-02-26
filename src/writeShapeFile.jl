function writeShapeFile(g::SimpleDiGraph, coords::Vector{Tuple{Float64,Float64}},
                      distmx::SparseArrays.SparseMatrixCSC{Float64,Int64},
                      traveltime::Dict{Any,Any},
                      outfile::String = "reduced.gpkg")
    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")

    pos = [geom.Point((lon, lat)) for (lat, lon) in coords]
    links = collect(edges(g))

    dist  = []
    geometry = []
    trtime = []
    for e in links
        s = e.src
        d = e.dst
        push!(geometry, geom.LineString([pos[s],pos[d]]))
        push!(dist, distmx[s,d])
        push!(trtime, distmx[s,d]/traveltime[(s,d)])
    end
    data = Dict("dist" => dist, "vel"=> trtime)
    gdf = gpd.GeoDataFrame(data=data, geometry=geometry)

    println("saving $outfile")

    gdf.to_file(outfile, layer="SimpleDiGraph", driver="GPKG")

    return outfile
end

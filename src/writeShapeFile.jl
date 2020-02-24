function writeShapeFile(g::SimpleDiGraph, coords::Vector{Tuple{Float64,Float64}},
                      distmx::Array{Float64, 2},
                      outfile::String = "reduced.gpkg")
    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")
    pos = [geom.Point(c) for c in coords]
    links = collect(edges(g))

    dist  = []
    geometry = []
    for e in links
        s = e.src
        d = e.dst
        push!(geometry, geom.LineString([pos[s],pos[d]]))
        push!(dist, distmx[s,d])
    end
    data = Dict("dist" => dist)
    gdf = gpd.GeoDataFrame(data=data, geometry=geometry)

    println("saving $outfile")

    gdf.to_file(outfile, layer="SimpleDiGraph", driver="GPKG")

    return outfile
end

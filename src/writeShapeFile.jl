function writeShapeFile(g::SimpleDiGraph, coords::Vector{Tuple{Float64,Float64}},
                      weightmx::SparseArrays.SparseMatrixCSC{Float64,Int64},
                      outfile::String = "reduced.gpkg")
    println("")
    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")

    pos = [geom.Point((lon, lat)) for (lat, lon) in coords]
    links = collect(edges(g))

    weight  = []
    geometry = []
    i=1
    for e in links
        s = e.src
        d = e.dst
        push!(geometry, geom.LineString([pos[s],pos[d]]))
        push!(weight, weightmx[s,d])
        i = i+1
    end
    data = Dict("weightmx" => weight)
    gdf = gpd.GeoDataFrame(data=data, geometry=geometry)

    println("saving $outfile")

    gdf.to_file(outfile, layer="SimpleDiGraph", driver="GPKG")

    return outfile
end

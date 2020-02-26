function getMapOSM(;place::String="",
                    location::Tuple{Float64,Float64}=(-3.7327, -38.5270),
                    radius::Float64=500.0,
                    nfile::String="data/nodes.csv",
                    efile::String="data/edges.csv",
                    city::String="",
                    )

    ox = pyimport("osmnx")
    nx = pyimport("networkx")

    if length(place) == 0
        G = ox.graph_from_point(location, distance=radius,
                                network_type="drive", simplify=true)
    else
        G = ox.graph_from_place(place,
                                network_type="drive", simplify=true)
    end

    println("")
    println("number of nodes = ", G.number_of_nodes())
    println("number of edges = ", G.number_of_edges())
    println("is directed = ", G.is_directed())
    x = nx.get_node_attributes(G, "x")
    y = nx.get_node_attributes(G, "y")
    idx = []
    lat = []
    lon = []
    nidx = []
    nodedic = Dict()
    for (i, node) in enumerate(G.nodes())
        push!(idx,i)
        push!(nidx, node)
        push!(lon, x[node])
        push!(lat, y[node])
        nodedic[node] = i
    end

    dfn = DataFrame(idx=idx, nidx=nidx, lat=lat, lon=lon)
    CSV.write(nfile, dfn)

    L = nx.get_edge_attributes(G, "length")
    uniqueedges = []
    for e in G.edges()
        s,d = e
        push!(uniqueedges, (s,d))
    end
    uniqueedges = unique(uniqueedges)


    edgelength = []
    src = []
    dst = []
    for e in uniqueedges
        s,d = e
        et = (s,d,0)
        push!(edgelength, L[et])
        push!(src, nodedic[s])
        push!(dst, nodedic[d])
    end
    #src,dst,length

    dfe = DataFrame(src=src, dst=dst, length=edgelength)
    CSV.write(efile, dfe)

    if length(city) > 0
        ox.save_graph_shapefile(G, filename=city, folder="data/")
    end
    return 1
end

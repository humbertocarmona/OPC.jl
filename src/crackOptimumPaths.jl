function crackOptimalPaths(g::SimpleDiGraph, org::Integer, dst::Integer,
                           traveltime::Dict{Any,Any},
    distmx::SparseArrays.SparseMatrixCSC{Float64,Int64}; N::Int64 = 0)

    if N == 0
        N = nv(g)
    end
    es = [(e.src, e.dst) for e in edges(g)]
    weightmx = [traveltime[e] for e in es]  # to to keep the order
    dij = LightGraphs.dijkstra_shortest_paths(g, org, weightmx)
    target = dest # first target is the destination
    sv = dij.predecessors[dest]
    havepath = size(sv,1) > 0
    print(havepath)
end

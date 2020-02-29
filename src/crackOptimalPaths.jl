function crackOptimalPaths(g::SimpleDiGraph, org::Int64, dst::Int64,
                           weightmx::SparseMatrixCSC{Float64,Int64};
                           nrem::Integer = 0)


    gr = copy(g)
    N = nv(gr)
    if nrem == 0
        nrem = N
    end
    dij = LightGraphs.dijkstra_shortest_paths(gr, org, weightmx, allpaths=true)
    sv = dij.predecessors[dst]
    havepath = size(sv,1) > 0

    removedmx = spzeros(N,N)
    n = 1
    while havepath && n < nrem
        # find maximum weight edge ----
        j = dst # first target is the destination
        i = dij.predecessors[j][1]
        ir, jr = i,j
        wmax =  weightmx[i,j]
        while i != org
            j = i
            i = dij.predecessors[j][1]
            w =  weightmx[i,j]
            if w > wmax
                wmax = w
                ir, jr = i, j
            end
        end # go through this path
        removedmx[ir, jr] = n

        rem_edge!(gr, ir, jr)
        dij = dijkstra_shortest_paths(gr, org, weightmx, allpaths=true) # re-eval Dijkstra
        sv = dij.predecessors[dst]
        havepath = size(sv,1) > 0
        # remove this edge and find new shortest path
        n = n + 1
    end # while havepath
    println()
    println("nremoved = $(n-1)")
    return gr, removedmx
end

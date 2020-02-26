function cellList(coords::Vector{Tuple{Float64,Float64}};
                  wcell::Float64 =200.0)
    """
        builds cell list for finding (origin, destination) within
        a given distance


    """


    nnodes = size(coords,1)

    x = []
    y = []
    for coord in coords
        lla = Geodesy.LLA(coord[1], coord[2], 0.0)
        recef = Geodesy.ECEF(lla, wgs84)
        push!(x, recef[1])
        push!(y, recef[2])
    end
    xmin, xmax = minimum(x), maximum(x)
    ymin, ymax = minimum(y), maximum(y)
    x = x .- xmin  #start from origin
    y = y .- ymin

    pos = [(x[i], y[i]) for i=1:nnodes]

    Lx = xmax-xmin # network size
    Ly = ymax-ymin
    nx = Int(ceil(Lx/wcell))
    ny = Int(ceil(Ly/wcell))
    dx = Lx/(nx-1)
    dy = Ly/(ny-1)
    cells = spzeros(Int, nx, ny)
    next = spzeros(Int, nnodes)
    for n in 1:nnodes
        i = Int(floor(x[n]/dx))+1
        j = Int(floor(y[n]/dy))+1
        if i > nx || j > ny
            println("($i, $j) vs. ($nx, $ny)")
        end
        p = cells[i,j]
        cells[i,j] = n
        next[n] = p
    end
    result = Dict("pos"=> pos,
                  "dx"=> dx, "dy"=>dy,
                  "nx"=> nx, "ny"=> ny,
                  "cells"=>cells,
                  "next"=>next)
end

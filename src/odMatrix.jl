function odMatrix(ℓ::Float64,
                     celllist::Dict{String,Any};
                     seed::Int64 = 11,
                     nOd::Int64 = 10,
                     nDstOrg::Int64=1)

    println(" ------------------------------")
    δ = max(0.05*ℓ, 100.0) # maximum error
    Random.seed!(seed)
    pos = celllist["pos"]
    nnodes = size(pos,1)
    dx = celllist["dx"]
    dy = celllist["dy"]
    nx = celllist["nx"]
    ny = celllist["ny"]
    cells = celllist["cells"]
    next = celllist["next"]

    odMatrix = []
    n = 0
    maxorig = 0
    while n < nOd && maxorig < 10*nOd
        org = rand(1:nnodes)
        rOrg = collect(pos[org])
        println("$n org = $org")
        for k=1:nDstOrg
            #find a nonempty cell, size dx x dy within ℓ, random angle
            foundCell = false
            ncelltries = 0
            cx, cy = 0, 0
            while ncelltries < 100
                trynonempy = 0
                while !foundCell && trynonempy < 10
                    ϕ = 2π * Random.rand()
                    rϕ = [ℓ*cos(ϕ), ℓ*sin(ϕ)]
                    rcell = rOrg + rϕ
                    cx, cy = Int(floor(rcell[1]/dx)), Int(floor(rcell[2]/dy))
                    if (0 < cx < nx) && (0 < cy < ny)
                        foundCell = (cells[cx,cy] > 0)
                        # println("\t [$cx, $cy]   try $ntries")
                    end
                    trynonempy = trynonempy + 1
                end
                if foundCell  # because trynonempy
                # find a destination at distance ℓ ± dx
                    dst = cells[cx, cy]
                    foundDst = false
                    while !foundDst && dst > 0  # limited by the nodes in cell
                        rDst = collect(pos[dst])
                        dr = rDst - rOrg
                        d = norm(dr)
                        foundDst = (abs(d-ℓ) < δ) && ((org,dst) ∉ odMatrix)
                        if foundDst
                            push!(odMatrix, (org,dst))
                            n = n + 1
                            if n ≥ nOd
                                break
                            end
                        end
                        dst = next[dst]  # next node in cell
                    end
                    # if !foundDst
                    #     println("\tno destination in this cell within range")
                    # end
                    if n ≥ nOd
                        break
                    end
                end
                ncelltries = ncelltries + 1
            end
            if n ≥ nOd
                break
            end
        end

        maxorig = maxorig + 1
    end
    return odMatrix
end

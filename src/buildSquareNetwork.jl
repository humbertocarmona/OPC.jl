function ij2n(i,j, nx)
    return i+nx*(j-1)
end

function n2ij(n, nx)
    j = (n-1)÷nx
    i = n-nx*j
    return i,j+1
end

function dist(β)
    """
    disorder
    """
    return exp(β*(Random.rand() - 1.0))
end

function buildSquareNetwork(nx::Int, ny::Int; p::Float64=0.5,
                            β::Float64=0.002, seed::Int64 = 123)
    """
        nx, ny: network size
        p: probability of bidirect edges
        β: desorder degree

        add one abobe the top row and one below to the bottom row

        add edges
        31---32---33---34---35---36      6
         |    |    |    |    |    |
        25---26---27---28---29---30      5
         |    |    |    |    |    |
        19---20---21---22---23---24      4
         |    |    |    |    |    |
        13---14---15---16---17---18      3
         |    |    |    |    |    |
         7----8----9---10---11---12      2
         |    |    |    |    |    |
         1----2----3----4----5----6      1
                                        ||
       I=1    2    3    4    5    6      J
    """

    Random.seed!(seed)
    nvertices = nx*ny
    nnodes = nvertices + 2 # last 2 are origin-destination
    g = SimpleDiGraph(nnodes)
    org = nvertices+1
    dst = nvertices+2
    distmx = spzeros(nnodes,nnodes)
    edgenumber = []

    en = 0
    center = [-3.7327, -38.5270]
    dx = dy = 9.0432e-4
    coords =  Tuple{Float64, Float64}[]
    # interior
    for i in 1:nx
        for j in 1:ny
            pos = center + [(i-1)*dx, (j-1)*dy]
            push!(coords, Tuple(pos))
            s=ij2n(i,j, nx)

            #add horizontal
            if i<nx
                d=ij2n(i+1,j, nx)
                ϵ = dist(β)
                unidirected = p < Random.rand()    # bidirected edge?
                if unidirected
                    right = Random.rand()>0.5 # choose direction
                    if right
                        ϵ = dist(β)
                        add_edge!(g, s,d)
                        distmx[s,d] = ϵ
                        en+=1
                        push!(edgenumber, en)
                    else
                        ϵ = dist(β)
                        add_edge!(g, d,s)
                        distmx[d,s] = ϵ
                        en+=1
                        push!(edgenumber, en)
                    end
                else # add bi-directed
                    ϵ = dist(β)
                    add_edge!(g, s,d)
                    distmx[s,d] = ϵ

                    ϵ = dist(β)
                    add_edge!(g, d,s)
                    distmx[d,s] = ϵ
                    en+=1
                    push!(edgenumber, en)
                end
            end

            #add vertical
            if j<ny
                d=ij2n(i,j+1, nx)


                unidirected = p < Random.rand()    # bidirected edge?
                if unidirected
                    up = Random.rand()>0.5 # choose direction
                    if up
                        ϵ = dist(β)
                        add_edge!(g, s,d)
                        distmx[s,d] = ϵ
                        en+=1
                    else
                        ϵ = dist(β)
                        add_edge!(g, d,s)
                        distmx[d,s] = ϵ
                    end
                    else # add bi-directed - each direction has a different weight
                    ϵ = dist(β)
                    add_edge!(g, s,d)
                    distmx[s,d] = ϵ

                    ϵ = dist(β)
                    add_edge!(g, d,s)
                    distmx[d,s] = ϵ
                end
            end
        end
    end

    # connects origin and destination
    for d=1:nx
        add_edge!(g, org, d)
        distmx[org,d] = 0.0
    end
    push!(coords, Tuple(center+[-1.0*dx, 0.5*(ny-1)*dy]))
    push!(coords, Tuple(center+[(nx+1.0)*dx, 0.5*(ny-1)*dy]))

    for s=nvertices-nx+1:nvertices
        add_edge!(g, s, dst)
        distmx[s,dst] = 0.0
    end

    return g, coords, distmx, 0
end

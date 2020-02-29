using DataFrames
using LightGraphs
using GraphPlot
using CSV
using Printf
using Colors
using SparseArrays
using Plots
using Compose, Fontconfig, Cairo
using Random

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

function createNetwork(nx::Int, ny::Int; p::Float64=0.5, β::Float64=0.002, seed = 123)
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
    nn = nx*ny
    nvertices = nn+2 # number of vertices
    g = SimpleDiGraph(nvertices)
    org = nn+1
    dst = nn+2


    distmx = spzeros(nvertices,nvertices)
    edgenumber = []
    en = 0
    # interior
    for i in 1:nx
        for j in 1:ny
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


    # origin and destination
    for d=1:nx
        add_edge!(g, org, d)
        distmx[org,d] = 0.0
    end

    for s=nn-nx+1:nn
        add_edge!(g, s, dst)
        distmx[s,dst] = 0.0
    end
    #distmx = transpose(sparse(transpose(distmx)))

    #define square lattice locations for plotting


    return g, distmx
end

function nodePropsPlotting(g)
    nvs = nv(g)
    nx = convert(Int, sqrt(nvs-2))
    nodelabel = collect(1:nvs)

    α_line = collect(1:nx)/nx
    alphas = []
    for α in α_line
        for _ in 1: nx
            push!(alphas,α)
        end
    end

    nodefillc = [RGBA(0.0,0.0,1.0,1) for i=1:nvs]
    for i in [1,nx]
        for j=1:nx
            n = ij2n(i,j,nx)
            nodefillc[n] = RGBA(1.0,0.0,0.0,1)
        end
    end

#     nodefillc = [RGBA(0.0,0.8,0.8,i) for i in alphas]
#     push!(nodefillc, RGBA(0.8,0.1,0.0,0.5))
#     push!(nodefillc, RGBA(0.0,0.1,0.8,0.5))


    locs_x=zeros(nvs)
    locs_y=zeros(nvs)
    for n=1:nvs
        i,j = n2ij(n, nx)
        locs_x[n] = i-0.5
        locs_y[n]= j-0.5
    end
    locs_x[nvs-1] = nx/2
    locs_x[nvs] = nx/2
    locs_y[nvs-1] = -1
    locs_y[nvs] = nx+1

    return nodelabel, nodefillc, locs_x, locs_y
end

function edgePropsPlotting(g, distmx; ncolors = 256)
    cmap = colormap("RdBu", ncolors)
    # need to map from 0-1 to 1-ncolors
    cmap = colormap("RdBu", ncolors)[end:-1:1]


    F = findnz(adjacency_matrix(g))
    edcolor = []
    c = 1
    for (i,j,val) in zip(F[1], F[2], F[3])
        d = distmx[i,j]
        k = Int(floor(ncolors*d))+1
        push!(edcolor, cmap[k])
        c+=1
    end
    edcolor
end

# g,distmx, edgenumber = createNetwork(5, 5, β=0.00001, p=0.0)
# ec1 = edgePropsPlotting(distmx)
# size(ec1), ne(g)

function test()
    nx = 8
    nvertices = nx*nx+2
    org = nx*nx+1
    dst = nx*nx+2

    g,distmx = createNetwork(nx, nx, β=6.0, p=0.5)
    nodelabel, nodefillc, loc_x, loc_y = nodePropsPlotting(g);
    ec1 = edgePropsPlotting(g, distmx)
    println(ne(g)," " ,size(ec1))
    p1 = gplot(g, loc_x, loc_y,
                nodefillc=nodefillc,
                NODESIZE=0.02,

                arrowlengthfrac=0.03,
                EDGELINEWIDTH=0.15,
                edgestrokec=ec1,
                arrowangleoffset = π/12,
                #edgelabel=edgenumber,
                )
    # draw(PNG("test.png", 16cm, 16cm),p1)
    p1
end
test()

function crack(g, distmx; orig=0, dest=0)
    if orig==0
        dest = nv(g)
        orig = dest-1
    end
    dij = dijkstra_shortest_paths(g, orig, distmx, allpaths=true);


    t = dest
    s = dij.predecessors[dest]
    havepath = size(s,1) >0

    remmx = spzeros(Int, nv(g), nv(g))
    whichpath = spzeros(Int, nv(g), nv(g))

    rem = 0
    while havepath
        s=s[1]
        deltamax = distmx[s,t]
        tmax = t
        smax = s
        while s != orig
            t = s
            s = dij.predecessors[t][1]
            delta = distmx[s,t]
            if whichpath[s,t] == 0
                whichpath[s,t] = rem+1
                if has_edge(g, t,s)
                    whichpath[t,s] = rem+1
                end
            end
            if delta > deltamax
                deltamax = delta
                tmax = t
                smax = s
            end
        end

        # println("removing $smax, $tmax, $deltamax")
        rem_edge!(g, smax, tmax)
        remmx[smax, tmax] = rem+1
        if has_edge(g,tmax,smax)
            rem_edge!(g, tmax, smax)
            remmx[tmax, smax] = rem+1
        end
        rem+=1

        dij = dijkstra_shortest_paths(g, orig, distmx, allpaths=true);
        t = dest
        s = dij.predecessors[t]
        havepath = size(s,1) >0
    end
    #println("no more paths is ", !havepath, " removed ", rem)
    return remmx, whichpath
end

function toGML(g, loc_x, loc_y, distmx, remmx, whichpath, filename)
    s = open(filename, "w") do file
    F = findnz(adjacency_matrix(g))

    write(file,"graph\n")
    write(file,"[\n")
    write(file,"  Creator \"Gephi\"\n")
    write(file,"  directed 1\n")
    n=0
    for i in 1:nv(g)-2
        x = 400*loc_x[i]
        y = 400*loc_y[i]
        write(file,"  node\n")
        write(file,"  [\n")
        write(file,"    id $n\n")
        write(file,"    label \"$n\"\n")
        write(file,"    graphics\n")
        write(file,"    [\n")
        write(file,"      x $x\n")
        write(file,"      y $y\n")
        write(file,"      z 0.0\n")
        write(file,"      w 10.0\n")
        write(file,"      h 10.0\n")
        write(file,"      d 10.0\n")
        write(file,"      fill \"#000000\"\n")
        write(file,"    ]\n")
        write(file,"  ]\n")
        n+=1
    end
    n=0
    for (k,l,v) in zip(F[1], F[2], F[3])
        if k < nv(g)-1 && l < nv(g)-1
            i=k-1
            j=l-1
            r = distmx[k,l]
            r = floor(r*10000)/10000
            rmm = remmx[k,l]
            wpath = whichpath[k,l]
            write(file,"  edge\n")
            write(file,"  [\n")
            write(file,"    id $n\n")
            write(file,"    source $i\n")
            write(file,"    target $j\n")
            write(file,"    weight $r\n")
            write(file,"    label $rmm\n")
            write(file,"    removed $rmm\n")
            write(file,"    whichpath $wpath\n")
            write(file,"  ]\n")
            n+=1
        end
    end
    write(file,"]")

    end
end

nav = 0
for seed in 1:1
    p = 0.5
    println("seed = $seed")
    flush(stdout)
    nx=6
    totalremoved = 0
    g,distmx = createNetwork(nx, nx, p=p, seed=seed)
    gc = copy(g)
    nodelabel, nodefillc, locs_x, locs_y = nodePropsPlotting(g)
    remmx, whichpath = crack(g, distmx; orig=0, dest=0)
    nremoved = -1
    if size(collect(findnz(remmx))[3],1)>0
        nremoved = maximum(findnz(remmx)[3])
    end
    p1 = gplot(g, locs_x, locs_y,
                nodefillc=RGBA(1.0,0.0,0.0,1),
                NODESIZE=0.015,

                arrowlengthfrac=0.07,
                EDGELINEWIDTH=0.5,
                edgestrokec=RGBA(0.0,0.0,1.0,1),
                arrowangleoffset = π/12
                )
    fname = "p$p.gml"
    #if nremoved == 10
        toGML(gc, locs_x, locs_y, distmx, remmx, whichpath, fname)
        display(p1)
    #end
    nav+=nremoved
end
print(nav)


repeat([HSV(91,1,1)],2)

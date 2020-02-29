using OPC
using LightGraphs
using JLD, HDF5
using SparseArrays
# using Plots

efile = "data/fortaleza_edges1.csv"
nfile = "data/fortaleza_nodes.csv"
# googlekey = "AIzaSyApQzC_OLdxiITS7ynh_XsWZZOU8XOKQHs"

# get network from Open Street Map
# dfe, dfn = OPC.getMapOSM(place="San Francisco, California, USA",
#                   nfile="data/sanfrancisco_nodes.csv",
#                   efile="data/sanfrancisco_edges.csv",
#                   city = "sanfrancisco")

# build LightGraph SimpleDiGraph from files or dataframes
g, coords, distmx, d = OPC.buildNetwork(efile, nfile)
# or
# g, coords, distmx, d = OPC.EdgeList2SimpleGraph(dfe, dfn)

# get all travelTimes for all edges in g
# datajson, output,  traveltimet = OPC.getTravelTimes(g, coords, googlekey)
traveltime = load("data/fortaleza_traveltime.jld", "traveltime")
N = nv(g)
weightmx = spzeros(N,N)
for e in edges(g)
    i, j = e.src, e.dst
    weightmx[i,j] = 0.06
    τ = traveltime[(i,j)]/distmx[i,j]
    if τ < 0.06
        println((i,j,τ))
    else
        weightmx[i,j] = τ
    end
end
# save shapefile from g
OPC.writeShapeFile(g, coords, weightmx,"data/fortaleza_map.gpkg")

res = OPC.cellList(coords; wcell=100.0)
OD = OPC.odMatrix(4500.0, res; nOd=1, nDstOrg=1)

gr, rmmx = OPC.crackOptimalPaths(g, 934, 41175, weightmx)

OPC.writeShapeFile(g, coords, rmmx,"rmmx_map.gpkg")

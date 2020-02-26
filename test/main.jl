using OPC
using LightGraphs
using JLD, HDF5

efile = "data/sanfrancisco_edges.csv"
nfile = "data/sanfrancisco_nodes.csv"
googlekey = "AIzaSyApQzC_OLdxiITS7ynh_XsWZZOU8XOKQHs"

# get network from Open Street Map
# dfe, dfn = OPC.getMapOSM(place="San Francisco, California, USA",
#                   nfile="data/sanfrancisco_nodes.csv",
#                   efile="data/sanfrancisco_edges.csv",
#                   city = "sanfrancisco")

# build LightGraph SimpleDiGraph from files or dataframes
g, coords, distmx, d = OPC.EdgeList2SimpleGraph(efile, nfile)
# or
# g, coords, distmx, d = OPC.EdgeList2SimpleGraph(dfe, dfn)

# get all travelTimes for all edges in g
# datajson, output,  traveltimet = OPC.getTravelTimes(g, coords, googlekey)
# traveltime = load("data/fortaleza_traveltime.jld", "traveltime")

# save shapefile from g
# OPC.writeShapeFile(g, coords, distmx,traveltime,"data/fortaleza.gpkg")

OPC.cellList(coords)

using OPC
using LightGraphs
using JLD, HDF5

efile = "data/fortaleza_nodes.csv"
nfile = "data/fortaleza_edges.csv"
googlekey = "AIzaSyApQzC_OLdxiITS7ynh_XsWZZOU8XOKQHs"
G = OPC.getMapOSM(place="San Francisco, California, USA",
                  nfile="data/sanfrancisco_nodes.csv",
                  efile="data/sanfrancisco_edges.csv",
                  city = "sanfrancisco")

# origin = (-3.729086,-38.507326)
# destination = (-3.747068,-38.575223)
# deptime = 0

# g, coords, distmx, d = OPC.EdgeList2SimpleGraph(efile, nfile)
# datajson, output = OPC.getGoogleDirection(origin, destination, deptime, key)
# data, output,  traveltimet = OPC.getTravelTimes(g, coords, googlekey)
# traveltime = load("data/fortaleza_traveltime.jld", "traveltime")
# OPC.writeShapeFile(g, coords, distmx,traveltime,"data/fortaleza.gpkg")


# save("data/fortaleza.jld", "data", dd)
# save("data/fortaleza_output.jld", "output", oo)
# save("fortaleza_traveltime.jld", "traveltime", tt)

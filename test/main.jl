using OPC
using LightGraphs
using JLD

efile = "data/edges_fortaleza.csv"
nfile = "data/nodes_fortaleza.csv"
googlekey = "AIzaSyApQzC_OLdxiITS7ynh_XsWZZOU8XOKQHs"
# origin = (-3.729086,-38.507326)
# destination = (-3.747068,-38.575223)
# deptime = 0

g, coords, distmx, d = OPC.EdgeList2SimpleGraph(efile, nfile)
# OPC.writeShapeFile(g, coords, distmx,"data/fortaleza.gpkg")
# datajson, output = OPC.getGoogleDirection(origin, destination, deptime, key)
dd, oo,  tt = OPC.getTravelTimes(g, coords, googlekey)

i = 1
for e in edges(g)
    s, d = e.src, e.dst
    println(i, " ", tt[(s,d)])
    if i==10
        break
    end
    global i = i + 1
end

save("fortaleza.jld", "data", dd)
save("fortaleza_output.jld", "output", oo)
save("fortaleza_traveltime.jld", "traveltime", tt)

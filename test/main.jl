using OPC

efile = "data/edges_fortaleza.csv"
nfile = "data/nodes_fortaleza.csv"
key = "AIzaSyApQzC_OLdxiITS7ynh_XsWZZOU8XOKQHs"
origin = (-3.729086,-38.507326)
destination = (-3.747068,-38.575223)
deptime = 0

# g, coords, distmx, d = OPC.EdgeList2SimpleGraph(efile, nfile)
# OPC.writeShapeFile(g, coords, distmx,"data/fortaleza.gpkg")
data = OPC.getGoogleDirection(origin, destination, deptime, key)

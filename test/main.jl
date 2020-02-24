using OPC

efile = "data/edges.csv"
nfile = "data/nodes.csv"

g, coords, distmx, d = OPC.EdgeList2SimpleGraph(efile, nfile)
OPC.writeShapeFile(g, coords, distmx,"data/simple.gpkg")

using OPC
g, coords, distmx, dummy = OPC.buildSquareNetwork(10,10)
OPC.writeShapeFile(g, coords, distmx,"squaremap.gpkg")

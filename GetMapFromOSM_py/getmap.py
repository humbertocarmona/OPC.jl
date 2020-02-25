# %%
import osmnx as ox
import networkx as nx
import pandas as pd

# %%
ox.config(log_console=False, use_cache=True)
ox.__version__


# %%
# if __name__ == "__main__":

place = 'San Francisco, California, USA'
city = "san_francisco"
place = ''
if place != '':
    print('getting from', place)
    # gdf = ox.gdf_from_place(place) # get contour as geopandas
    G = ox.graph_from_place(place, network_type='drive',
                            simplify=True)  # get map as networkx
    print(G.number_of_nodes())
    print(G.number_of_edges())
    print(G.is_directed())
else:
    location_point = (-3.7327, -38.5270)  # Fortaleza
    city = "fortaleza"
    # location_point = (37.691331, -122.310746)  # San Francisco Bay
    # city = "san_francisco_bay"
    distance = 15000
    print('getting from', location_point, distance/1000, 'km')
    G = ox.graph_from_point(location_point, network_type='drive',
                            distance=distance, simplify=True)
    print(G.number_of_nodes())
    print(G.number_of_edges())
    print(G.is_directed())

#ox.save_graphml(G, filename="tt.graphml")

# %% get node properties

pos = {}
nDic = {}
x = nx.get_node_attributes(G, "x")
y = nx.get_node_attributes(G, "y")
t = nx.get_node_attributes(G, "highway")
idx = []
lat = []
lon = []
n_idx = []

for i, n in enumerate(G.nodes()):
    idx.append(i+1)
    n_idx.append(n)
    lon.append(x[n])
    lat.append(y[n])
    nDic[n] = i+1
    pos[n] = (x[n], y[n])
    # if n in t:
    #     print(i+1, t[n])

df = pd.DataFrame({'i': idx, 'n': n_idx, 'lat': lat, 'lon': lon})
nfile = "../data/nodes_{:}.csv".format(city)
df.to_csv(nfile, index=False)

# %%
src = []
dst = []
lgt = []
i = 0
L = nx.get_edge_attributes(G, "length")

i=0
inside = []
for e in G.edges():
    s, d = e
    if (s,d) in inside:
        print("warning {:},{:} duplicate".format(nDic[s],nDic[d]))
    else:
        inside.append((s,d))
        src.append(nDic[s])
        dst.append(nDic[d])
        ed = (s,d,0)
        if ed in L:
            lgt.append(L[ed])
        else:
            lgt.append(0.0)
        i = i+1


df = pd.DataFrame({'src': src, 'dst': dst, 'length':lgt})
efile = "../data/edges_{:}.csv".format(city)
df.to_csv(efile, index=False)
ox.save_graph_shapefile(G, filename=city, folder='../data/')

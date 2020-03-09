using OPC
using LightGraphs
using JLD, HDF5
using SparseArrays
using Dates
using Statistics
using CSV, DataFrames
using LaTeXStrings
using LsqFit
using Printf
using Plots
using Plots.PlotMeasures
using Logging

"""
    to get get network from Open Street Map
    dfe, dfn = OPC.getMapOSM(place="San Francisco, California, USA",
                      nfile="data/sanfrancisco_nodes.csv",
                      efile="data/sanfrancisco_edges.csv",
                      city = "sanfrancisco")

    build LightGraph SimpleDiGraph from files or dataframes
        g, coords, distmx, d = OPC.buildCityNetwork(efile, nfile)
    or
        g, coords, distmx, d = OPC.EdgeList2SimpleGraph(dfe, dfn)

    get all travelTimes for all edges in g
        datajson, output,  traveltimet = OPC.getTravelTimes(g, coords, googlekey)
"""


pyplot()
PyPlot.rc("text", usetex = "true")
PyPlot.rc("font", family = "CMU Serif")

io = open("log.txt", "w+")
logger = SimpleLogger(io, Logging.Debug)
global_logger(logger)


city = "fortaleza"
efile = "data/fortaleza_edges1.csv"
nfile = "data/fortaleza_nodes.csv"
# googlekey = "AIzaSyApQzC_OLdxiITS7ynh_XsWZZOU8XOKQHs"

df = DataFrame(L = [], nr = [], err = [])
fnamecsv = "data/tt.csv"
L = [500.0, 1000.0, 1500.0, 2000.0, 3500.0, 4000.0]
nsamples = 100
g, coords, distmx, d = OPC.buildCityNetwork(efile, nfile)
weightmx = getWeights()

with_logger(logger) do
    for ℓ in L
        seed = Dates.value(DateTime(Dates.now()))
        res_cellList = OPC.cellList(coords; wcell=100.0)
        OD = OPC.odMatrix(ℓ, res_cellList; nSamples=nsamples, nDstOrg=1, seed=seed)
        global nremoved = []
        for sample=1:nsamples
            (orig, dest)  = OD[sample]
            nrem, gr, rmmx = OPC.crackOptimalPaths(g, orig, dest, weightmx)
            if mod(sample, 10)==0
                @debug("ℓ = $ℓ, sample = $sample, od = ($orig, $dest) removed = $nrem")
                flush(io)
            end
            if sample == 1 && L == 2000.0
                fname = "data/$(city)_L$(ℓ)_map.gpkg"
                OPC.writeShapeFile(g, coords, rmmx, fname)
            end
            push!(nremoved, nrem)
        end
        μ = mean(nremoved)
        ϵ = std(nremoved)/sqrt(nsamples)
        push!(df, [ℓ μ ϵ])
        CSV.write(fnamecsv, df)
        @debug("\tℓ = $ℓ, μ = $μ, ϵ = $ϵ ")
        flush(io)
    end
end

function getWeights(fname = "data/fortaleza_traveltime.jld")
    traveltime = load(fname, "traveltime")
    N = nv(g)
    weightmx = spzeros(N,N)
    for e in edges(g)
        i, j = e.src, e.dst
        weightmx[i,j] = 0.06
        τ = traveltime[(i,j)]/distmx[i,j]
        if τ > 0.06
            weightmx[i,j] = τ
        end
    end
    return weightmx
end

close(io)

using OPC
using Geodesy
# using LightGraphs
# using SparseArrays
using Dates
using Statistics
using CSV, DataFrames
using Logging
using ArgParse

# googlekey = "AIzaSyApQzC_OLdxiITS7ynh_XsWZZOU8XOKQHs"


function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--l1"
            arg_type = Float64
            default = 1000.0
        "--l2"
            arg_type = Float64
            default = 1000.0
        "--dl"
            arg_type = Float64
            default = 500.0
        "--nsamples", "-n"
            arg_type = Int
            default = 500
        "--run", "-r"
            arg_type = Int
            default = 1
        "--efile"
            arg_type = String
            required = true
        "--nfile"
            arg_type = String
            required = true
    end

    return parse_args(s)
end

parsed_args = parse_commandline()

l1 = parsed_args["l1"]
l2 = parsed_args["l2"]
dl = parsed_args["dl"]
ns = parsed_args["nsamples"]
run = parsed_args["run"]
efile = parsed_args["efile"]
nfile = parsed_args["nfile"]
city = split(nfile,"/")[end]
city = split(city,"-")[1]

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

tinit = Dates.format(now(), "ddmmyy-HHhMM-SS")
println("")
println(tinit)

io = open("logs/run$run-$tinit.log", "w+")
logger = SimpleLogger(io, Logging.Debug)
global_logger(logger)


L = collect(l1:dl:l2)
g, coords, distmx, weightmx, d = OPC.buildCityNetwork(efile, nfile)
rcellList = OPC.cellList(coords; cellWidth=100.0)
with_logger(logger) do
    @info(Dates.format(Dates.now(), "yy-mm-dd H:M"))
    flush(io)
    for ℓ in L
        seed = Dates.value(DateTime(Dates.now()))
        OD = OPC.odMatrix(ℓ, rcellList; ns=ns, seed=seed, δ = 0.01)
        nremoved = []
        dist = []
        for sample=1:ns
            (orig, dest)  = OD[sample]
            p1 = LLA(coords[orig][1], coords[orig][2], 0.0)
            p2 = LLA(coords[dest][1], coords[dest][2], 0.0)
            nrem, gr, rmmx = OPC.crackOptimalPaths(g, orig, dest, weightmx)
            if mod(sample, 10)==0
                @debug("ℓ = $ℓ, sample = $sample, $(mean(nremoved))")
                flush(io)
            end
            push!(nremoved, nrem)
            push!(dist, distance(p1,p2))
        end
        fn = "results/$city-nr-$run-l-$(Int(round(ℓ))).csv"
        df = DataFrame(ell=dist, nr=nremoved)
        CSV.write(fn, df)
    end
end

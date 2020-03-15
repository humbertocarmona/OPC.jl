using OPC
using Geodesy
using Dates
using Statistics
using CSV, DataFrames
using Logging
using ArgParse

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
        "--nx"
            arg_type = Int
            default = 80
        "--runid"
            arg_type = Int
            default = 1
        "--prob"
            arg_type = Float64
            default = 0.6
        "--beta"
            arg_type = Float64
            default = 0.002
        end
    return parse_args(s)
end

parsed_args = parse_commandline()

l1 = parsed_args["l1"]
l2 = parsed_args["l2"]
dl = parsed_args["dl"]
ns = parsed_args["nsamples"]
runid = parsed_args["runid"]
p = parsed_args["prob"]
β = parsed_args["beta"]
nx = parsed_args["nx"]


mkpath("logs")
mkpath("results")

tinit = Dates.now()
tinits = Dates.format(tinit, "ddmmyy-HHhMM-SS")
io = open("logs/run$runid-$tinits.log", "w+")
logger = SimpleLogger(io, Logging.Debug)
global_logger(logger)
with_logger(logger) do
    @info("--------------------------
    $(Dates.format(tinit, "yy-mm-dd H:M"))
    runid = $runid, square lattice $nx x $nx, p = $p β = $β
    L = [$l1:$dl:$l2], nsamples = $ns
    --------------------------")
    flush(io)
    # if here, same network for each ℓ
    for ℓ in collect(l1:dl:l2)
        # if here, one network for each ℓ
        nremoved = []
        measdist = []
        for sample = 1:ns
            # if here, one network for each od....
            seed = Dates.value(DateTime(Dates.now()))
            g, coords, weightmx,dd = OPC.buildSquareNetwork(nx, nx, p = p, β = β,seed=seed, od=false)
            res_cellList = OPC.cellList(coords; cellWidth=100.0)
            OD = OPC.odMatrix(ℓ, res_cellList;
                               nDstOrg=1,
                               seed=seed,
                               ns=1,
                               square=false,
                               δ = 0.001)

            (orig, dest)  = OD[1]

            p1 = LLA(coords[orig][1], coords[orig][2], 0.0)
            p2 = LLA(coords[dest][1], coords[dest][2], 0.0)
            nrem, gr, rmmx = OPC.crackOptimalPaths(g, orig, dest, weightmx)
            # if sample == 1 && ℓ==4000.0
            #     fname = "results/l$(ℓ)-beta$(β)-p$(p).gpkg"
            #     OPC.writeShapeFile(g, coords, rmmx,fname)
            # end
            if mod(sample, 100)==0
                @debug("ℓ = $ℓ, sample = $sample, $(mean(nremoved))")
                flush(io)
            end
            push!(nremoved, nrem)
            push!(measdist, distance(p1,p2))
        end
        fn = "results/square-nr-$runid-l-$(Int(round(ℓ))).csv"
        df = DataFrame(ell=measdist, nr=nremoved)
        CSV.write(fn, df)
    end
    tend = Dates.now()
    tinits = Dates.format(tinit, "ddmmyy-HHhMM-SS")
    dur = Dates.canonicalize(Dates.CompoundPeriod(tend-tinit))
    @info("----------- finished -----------------
    $(Dates.format(tend, "yy-mm-dd H:M"))
    took  $dur
    --------------------------------------------")
    flush(io)
end
close(io)

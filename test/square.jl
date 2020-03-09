using OPC
using Test
using Dates
using Statistics
using CSV, DataFrames
using Logging
using Geodesy


df = DataFrame(L = [], dist = [], errdist = [], nr = [], errne = [])
fnamecsv = "data/sq128_1000.csv"
L = collect(1000.0:1000.0:10000.0)
ns = 1000
p = 0.6
β = 0.002

seed = Dates.value(DateTime(Dates.now()))
g, coords, weightmx,dd = OPC.buildSquareNetwork(128, 128, p = p, β = β,
                                                seed = seed, od=false)
res_cellList = OPC.cellList(coords; cellWidth=100.0)

io = open("log.txt", "w+")
logger = SimpleLogger(io, Logging.Debug)
global_logger(logger)
with_logger(logger) do
    for ℓ in L
        nremoved = []
        dist = []
        seed = Dates.value(DateTime(Dates.now()))
        OD = OPC.odMatrix(ℓ, res_cellList;
                           nDstOrg=1,
                           seed=seed,
                           ns=ns,
                           square=false,
                           δ = 0.001)
        @debug("ℓ = $ℓ, size(OD,1)=$(size(OD,1))")
        Threads.@threads for sample = 1:ns
            (orig, dest)  = OD[sample]
            p1 = LLA(coords[orig][1], coords[orig][2], 0.0)
            p2 = LLA(coords[dest][1], coords[dest][2], 0.0)
            push!(dist, distance(p1,p2))
            nrem, gr, rmmx = OPC.crackOptimalPaths(g, orig, dest, weightmx)
            push!(nremoved, nrem)
            if sample == 1 && ℓ==4000.0
                fname = "data/sq_L$(ℓ)_map.gpkg"
                OPC.writeShapeFile(g, coords, rmmx,fname)
            end
            if mod(sample, 100)==0
                @debug("ℓ = $ℓ, sample = $sample, $(mean(nremoved))")
                flush(io)
            end
        end
        ll = mean(dist)
        sl = std(dist)/sqrt(ns)
        μ = mean(nremoved)
        ϵ = std(nremoved)/sqrt(ns)
        push!(df, [ℓ ll sl μ ϵ])
        CSV.write(fnamecsv, df)
        @debug("\tℓ = $ℓ, dist = $ll ϵ = $sl μ = $μ, ϵ = $ϵ ")
        flush(io)
    end
end
close(io)

@testset "OPC.jl" begin
    @test true
end

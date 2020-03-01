using OPC
using Dates
using Statistics
using CSV, DataFrames
using Logging
using Plots
using Plots.PlotMeasures
using LaTeXStrings
using Distributed
io = open("log.txt", "w+")
logger = SimpleLogger(io, Logging.Debug)

pyplot()
PyPlot.rc("text", usetex = "true")
PyPlot.rc("font", family = "CMU Serif")

global_logger(logger)


df = DataFrame(L = [], nr = [], err = [])
fnamecsv = "data/tt.csv"
CSV.write(fnamecsv, df)
println()
L = [16, 32, 64, 128, 256]
nsamples = 1000
p = 1.0
β = 0.002
with_logger(logger) do
    for ℓ in L
        nremoved = []
        for sample = 1:nsamples
            if mod(sample, 100)==0
                @debug("ℓ = $ℓ, sample = $sample")
                flush(io)
            end
            seed = Dates.value(DateTime(Dates.now()))
            g, coords, distmx,dd = OPC.buildSquareNetwork(ℓ, ℓ, p = p, β = β, seed = seed)
            if sample == 1
                fname = "sq_L$(ℓ)_map.gpkg"
                OPC.writeShapeFile(g, coords, distmx,fname)
            end
            orig = ℓ^2+1
            dest = ℓ^2+2
            nrem, gr, rmmx = OPC.crackOptimalPaths(g, orig, dest, distmx)
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

close(io)

df05 = CSV.read("data/sq_nr_p05.csv")

p1 = plot(
    size = (400, 300),
    legendfontsize = 9,
    legend=:topleft,
    top_margin = 3mm,
    bottom_margin = 3mm,
    left_margin=3mm,
    right_margin=3mm,
    fg_legend = :white,
    dpi = 150,
    framestyle = :box,
    #xaxis = (L"Re", [0.4, 700],  [1, 10, 100, 1000], font(15), :log),
    #yaxis = (L"G", [11.35, 1000], [10, 100, 1000], font(15), :log),
    xaxis =(L"\ell", [10,200],[10,100,1000],:log, font(15)),
    yaxis = (L"N_r",[1,10000],[1,10,1e2,1e3, 1e4],:log, font(15)),
    grid = false,
    # thickness_scaling=1.1
)

scatter!(df.L, df.nr,label = L"p = 1.0",
                     markersize=9, c=1  )
x=12:180
y=0.55x.^1.
plot!(x, y, label="", c=:black)


scatter!(df05.L, df05.nr,label = L"p = 0.5",
                     markersize=9, marker=:utriangle,
                     c=2, alpha=0.8)

x=12:180
y=0.14x.^2
plot!(x, y, label="", c=:black)

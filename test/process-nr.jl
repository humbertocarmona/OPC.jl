using CSV, DataFrames
using Plots
using Statistics
plotly()
include("utils.jl")

city = "square"
L=[1000, 1500, 2000, 2500, 3000, 3500, 4000,4500]

lav = []
lerr = []
nrav = []
nrerr = []
df = CSV.read
for ℓ in L
    fn = "results/$city-nr-l-$(ℓ).csv"
    df = DataFrame()
    if isfile(fn)
        df = CSV.read(fn)
    end
    files = findFilesMaching("$(city)"r"-nr-.+-l-"*"$(ℓ)"r".csv", "results")
    println("$(size(files,1)) files for $ℓ")
    for f in files
        dfi = CSV.read(f)
        df = [df; dfi]
    end
    # fn = "results/c-$city-nr-00-l-$(ℓ).csv"
    # CSV.write(fn, df)
    n = size(df,1)
    d = mean(df.ell)
    derr = std(df.ell)/sqrt(n)
    nr = mean(df.nr)
    nre = std(df.nr)/sqrt(n)
    push!(lav,d)
    push!(lerr, derr)
    push!(nrav, nr)
    push!(nrerr, nre)
end

scatter(lav, nrav, xerror=lerr, yerror=nrerr)
y=0.03*L .+ 50
plot!(L,y)

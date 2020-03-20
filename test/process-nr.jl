using CSV, DataFrames
using Plots
using Statistics
using PlotThemes

plotly()
theme(:default)
include("utils.jl")

city = "square"
L=[1000, 1500, 2000, 2500, 3000, 3500, 4000,4500]

lav = []
lerr = []
nrav = []
nrerr = []
df = CSV.read
folders=["results/square/p06beta002/","results/square/p06boston//"]
folders=["results/square/p06boston//"]
p1 = scatter(xaxis=(:log), yaxis=(:log))
for folder in folders
    for ℓ in L
        df = DataFrame()
        files = findFilesMaching("$(city)"r"-nr-.+-l-"*"$(ℓ)"r".csv", folder)
        println(files)

        for f in files
            dfi = CSV.read(f)
            df = [df; dfi]
        end
        # fn = "results/square/results/c-$city-nr-00-l-$(ℓ).csv"
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
        println("$(size(files,1)) files for $ℓ, total $n realizations")
    end

    scatter!(lav, nrav, xerror=lerr, yerror=nrerr, xaxis=(:log), yaxis=(:log))
end
p1

 

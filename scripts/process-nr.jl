using CSV, DataFrames
using Plots
using Statistics
using PlotThemes
using LaTeXStrings
pyplot()
theme(:wong2)
include("utils.jl")

city = "square"
L=[1000, 1500, 2000, 2500, 3000, 3500, 4000,4500]

df = CSV.read
folders=["p0.6beta0.002","p0.6beta1.800","results", "p0.6boston"]
# folders=["p0.6beta0.002/","results/","p0.6beta200.0/", "p0.6boston//"]
labels=[L"\beta = 0.002",L"\beta = 1.800",L"\beta = 200.0", L"Boston \; dist"]

# folders=["results",]
# labels=[L"Boston \; dist"]


p1 = scatter(xaxis=(:log), yaxis=(:log))
for (folder, lab) in zip(folders,labels)
    lav = []
    lerr = []
    nrav = []
    nrerr = []
    for ℓ in L
        df = DataFrame()
        files = findFilesMaching("$(city)"r"-nr-.+-l-"*"$(ℓ)"r".csv", folder)
        for f in files
            dfi = CSV.read(f)
            df = [df; dfi]
        end
        # fn = "$folder/c-$city-nr-00-l-$(ℓ).csv"
        # CSV.write(fn, df)
        n = size(df,1)
        println("$folder $(size(files,1)) files, $n points")
        d = mean(df.ell)
        derr = std(df.ell)/sqrt(n)
        nr = mean(df.nr)
        nre = std(df.nr)/sqrt(n)
        push!(lav,d)
        push!(lerr, derr)
        push!(nrav, nr)
        push!(nrerr, nre)
    end

    p1 = scatter!(lav, nrav, xerror=lerr, yerror=nrerr,markersize=8, label=lab)
end
p1

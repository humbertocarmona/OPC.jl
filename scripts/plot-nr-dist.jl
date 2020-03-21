using CSV, DataFrames
using Plots, PlotThemes
using Random, Distributions
using LaTeXStrings
pyplot()
PyPlot.rc("text", usetex = "true")
PyPlot.rc("font", family = "CMU Serif")

theme(:wong2)
# https://github.com/JuliaPlots/PlotThemes.jl
# Plots.showtheme(:vibrant)

include("utils.jl")
files = findFilesMaching(r"square-nr-00-l-.+\.csv","./results/square/p06beta002")
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
    xaxis = (L"nr"), yaxis=(L"\log_{10}\;P(nr)"),
    grid = false,
    # thickness_scaling=1.1
)
for f in files
    fname = split(f, ".csv")[1]
    fname = split(fname, "/")[end]
    fname = split(fname, "-")[end]

    df = CSV.read(f)|> DataFrame
    nr = df.nr
    n = size(nr,1)
    mi = minimum(nr)
    ma = maximum(nr)

    edges = collect(range(mi, stop=ma, length=30))
    w = edges[2:end] - edges[1:end-1]
    h, c = hist(nr, edges, norm=true)
    i = findall(x->x>0.0, h)
    h = h[i]
    c = c[i]
    i = findall(x->x>0.0, c)
    h = h[i]
    c = c[i]
    l=L"L = "*"$(fname)"*L", \left<nr\right> = "*"$(round.(mean(nr); digits=1))"
    plot!(c, log10.(h), label=l)
end
p1

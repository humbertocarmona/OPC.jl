using OPC
using CSV, DataFrames
using Plots, PlotThemes
using Random, Distributions
plotly()
theme(:wong2)
# https://github.com/JuliaPlots/PlotThemes.jl
# Plots.showtheme(:vibrant)
include("utils.jl")
df = CSV.read("data/boston-edges-4h.csv")|> DataFrame
dados = df.tt ./ df.len
n = size(dados,1)
edges = collect(0:0.02:0.75)
w = edges[2:end] - edges[1:end-1]
h1, c1 = hist(dados, edges, norm=true)
plot(c1, h1)
df = CSV.read("test/vals.csv")|> DataFrame
dados = df.val
n = size(dados,1)
edges = collect(0:0.02:0.75)
w = edges[2:end] - edges[1:end-1]
h2, c2 = hist(dados, edges, norm=true)
plot!(c2, h2)

# f = fit_mle(LogNormal, dados)
#
# data = Random.rand(f,100000)
# h2, c2 = hist(data, edges, norm=true)
# plot!(c2, h2)
#
# x = range(0, 0.75; length = 100)
# pdf.(f, x)
# plot!(x, pdf.(f, x))

# d = OPC.DisorderDist(1)
# data = [OPC.rand(d) for i in 1:100000]
# edges = 10.0.^(range(-3,stop=0,length=100))
# # edges = collect(0:0.001:1)
# h, c = hist(data, edges, norm=true)
# idx = findall(x->x>0,h)
# scatter(c[idx],h[idx], xaxis=(:log),yaxis=(:log))
# plot!(c[idx],0.05c[idx].^(-1.0), xaxis=([0.1,1.0],:log),yaxis=(:log))
# Random.rand(d)

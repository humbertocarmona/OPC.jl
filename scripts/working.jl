# using OPC
# using Plots, PlotThemes
# using CSV, DataFrames
using Distributions
using Random
using Plots
include("utils.jl")
pyplot()

##--
# just generate a PDF of a given distribution in the interval [xmin, xmax]
d = LogNormal()
xmin, xmax = 0, 10.0
dx = 0.05
x=collect(xmin:dx:xmax)
y = pdf.(d,x)
ymax =maximum(y)
maximum(y)
scatter(x, y)
##--

#---
# 1 - generate    xmin < xr < xmax
# 2 - find the index of xr in your array x
# 3 - generate         0  < yr < maximum(y)
# 4 - if yr < y[index] accept

vals = []
n = 1000000
for i in 1:n
    xr = (xmax-xmin)*(rand()) + xmin
    index = Int(round((xr-xmin)/dx))+1
    yr = rand()*0.4
    while yr > y[index]
        xr = (xmax-xmin)*(rand()) + xmin
        index = Int(round((xr-xmin)/dx))+1
        yr = rand()*ymax
    end
    if yr < y[index]
        push!(vals,xr)
    end
end
vals= convert(Array{Float64,1}, vals)

h,c = hist(vals, x, norm=true)

plot!(c,h)


#---
# import Random:rand
#
# struct DisorderDist <: ContinuousUnivariateDistribution
#     beta::Float64
#     DisorderDist(beta) = new(Float64(beta))
# end
#
#
# function Random.rand(s::DisorderDist)
#     return exp(s.beta*(Random.rand() - 1.0))
# end
#
# d = DisorderDist(0.002)
# Random.rand(d)
# d = Normal()
# rand(d)

#---
# plotly()
# theme(:wong2)
# # https://github.com/JuliaPlots/PlotThemes.jl
# # Plots.showtheme(:vibrant)
# include("utils.jl")
# df = CSV.read("data/boston-edges-4h.csv")|> DataFrame
# dados = df.tt ./ df.len
# n = size(dados,1)
# edges = collect(0:0.02:0.75)
# w = edges[2:end] - edges[1:end-1]
# h1, c1 = hist(dados, edges, norm=true)
# plot(c1, h1)
# df = CSV.read("test/vals.csv")|> DataFrame
# dados = df.val
# n = size(dados,1)
# edges = collect(0:0.02:0.75)
# w = edges[2:end] - edges[1:end-1]
# h2, c2 = hist(dados, edges, norm=true)
# plot!(c2, h2)

#---
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

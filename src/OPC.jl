module OPC

using DataFrames
using CSV
using LightGraphs
using SparseArrays
using PyCall
using HTTP
using JSON
using Dates
using Random
using Geodesy
using Statistics
using LinearAlgebra
using Logging

function __init__()
    global logger = SimpleLogger(stdout, Logging.Info)
    global_logger(logger)
end

include("getGoogleDirection.jl")
include("getTravelTimes.jl")
include("getMapOSM.jl")
include("buildCityNetwork.jl")
include("buildSquareNetwork.jl")
include("cellList.jl")
include("odMatrix.jl")
include("crackOptimalPaths.jl")
include("writeShapeFile.jl")
include("writeGML.jl")
end # module

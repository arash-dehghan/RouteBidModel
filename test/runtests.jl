using Pkg

Pkg.add("LightGraphs")
Pkg.add("SimpleWeightedGraphs")
Pkg.add("OpenStreetMapX")
Pkg.add("OpenStreetMapXPlot")
Pkg.add("DataFrames")
Pkg.add("DataFramesMeta")
Pkg.add("Distributions")
Pkg.add("CSV")
Pkg.add("Compose")
Pkg.add("Random")
Pkg.add("IJulia")
Pkg.add("Conda")
Pkg.add("PyCall")

using Test
using OpenStreetMapX, OpenStreetMapXPlot
using LightGraphs, SimpleWeightedGraphs
using DataFrames, DataFramesMeta
using Compose
using Distributions
using CSV
using DelimitedFiles
using SparseArrays
using Random
using Conda
using PyCall

include("../src/decls.jl")
include("../src/osm_convert.jl")
include("../src/Visuals.jl")

Random.seed!(0)

path = "maps//"
file = "buffaloF.osm"

nw = CreateNetworkFromFile(path, file)
Decls.SetSpawnAndDestPts!(nw, Decls.GetNodesOutsideRadius(nw,(-2000.,-2000.),4000.), Decls.GetNodesInRadius(nw,(-2000.,-2000.),2000.))

sim = Decls.Simulation(nw, 2 * 60, maxAgents = 350, dt = 15.0, initialAgents = 200, auctions = true)

@time Decls.RunSim(sim)

CSV.write(raw".\results\history.csv", sim.simData)
CSV.write(raw".\results\roadInfo.csv", sim.roadInfo)
CSV.write(raw".\results\coords.csv", Decls.GetIntersectionCoords(sim.network))
CSV.write(raw".\results\interInfo.csv", Decls.DumpIntersectionsInfo(nw, map, mData))
write(raw".\results\auctions.txt", Decls.DumpAuctionsInfo(sim))
open(raw".\results\auctions.txt", "w") do f
    write(f, "A, B, C, D\n")
end
writedlm(raw".\results\log.txt", Decls.simLog, "\n")

map = OpenStreetMapX.parseOSM(raw"maps\buffaloF.osm")
crop!(map)
mData = get_map_data("maps", "buffaloF.osm")

Visuals.GraphAgents(map, mData, nw.agents)

#test czy alter route cost > best route cost
pth = dijkstra_shortest_paths(nw.graph,4228)

sp = sparse([1, 2], [3, 6], [4.54, 6.65])
sp[54][67] = 45.90
sp = spzeros(10, 10)
sp[5,4] = 433

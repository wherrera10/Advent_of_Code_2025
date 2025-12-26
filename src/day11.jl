using BenchmarkTools

using Graphs
using Memoization

""" memoized recursive DFS function to count paths from current to target """
@memoize function count11paths(graph::SimpleDiGraph, current::Int, target::Int, visited::Set{Int})::Int
    if current == target
        return 1
    end
    total = 0
    for neighbor in neighbors(graph, current)
        if neighbor ∉ visited
            push!(visited, neighbor)
            total += count11paths(graph, neighbor, target, visited)
            delete!(visited, neighbor)
        end
    end
    return total
end

function day11()
    part = [0, 0]
    devices = Dict{String, Int}()
    dnumber = 1
    links = Dict{Int, Vector{Int}}()
    for line in eachline("day11.txt")
        nodes = split(line, r"[\s:]+")
        for n in nodes
            if !haskey(devices, n)
                devices[n] = dnumber
                dnumber += 1
            end
        end
        if haskey(links, devices[nodes[begin]])
            append!(links[devices[nodes[begin]]], map(k -> devices[k], nodes[(begin+1):end]))
        else
            links[devices[nodes[begin]]] = map(k -> devices[k], nodes[(begin+1):end])
        end
    end
    graph = SimpleDiGraph(length(devices))
    for (parent, children) in links
        for n in children
            add_edge!(graph, parent, n)
        end
    end
    svr, out, you, dac, fft = devices["svr"], devices["out"], devices["you"], devices["dac"], devices["fft"]
    part[1] = length(collect(all_simple_paths(graph, you, out)))

    part[2] =
        count11paths(graph, svr, fft, Set{Int}()) * count11paths(graph, fft, dac, Set{Int}()) *
        count11paths(graph, dac, out, Set{Int}())

    return part # [607, 506264456238938]
end

@btime day11()
@show day11()

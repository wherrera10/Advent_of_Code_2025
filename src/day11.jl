using BenchmarkTools

using Memoization

""" memoized recursive DFS function to count paths from current to target without visited """
@memoize function count11paths(mat::BitMatrix, ncols::Int, current::Int, target::Int, visited::BitVector)::Int
    if current == target
        return 1
    end
    total = 0
    for i in 1:ncols
        if mat[current, i] && !visited[i]
            visited[i] = true
            total += count11paths(mat, ncols, i, target, visited)
            visited[i] = false
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
    matdim = dnumber - 1
    mat = falses(matdim, matdim)
    visited = falses(matdim)
    for i in keys(links)
        for j in links[i]
            mat[i, j] = true
        end
    end
    svr, out, you, dac, fft = devices["svr"], devices["out"], devices["you"], devices["dac"], devices["fft"]
    part[1] = count11paths(mat, matdim, you, out, visited)
    part[2] =
        count11paths(mat, matdim, svr, fft, visited) * count11paths(mat, matdim, fft, dac, visited) *
        count11paths(mat, matdim, dac, out, visited)

    return part # [607, 506264456238938]
end

@btime day11()
@show day11()

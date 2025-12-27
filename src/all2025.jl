"""
 Day     Seconds
=================
day01   0.000221
day02   0.0744389
day03   0.0001372
day04   0.0028733
day05   0.0001553
day06   0.0010913
day07   0.0001078
day08   0.0272397
day09   0.0052549
day10   0.3059402
day11   0.0014705
day12   0.0008629
=================
Total   0.419793
"""

using LinearAlgebra
using BenchmarkTools
using Graphs
using Memoization
using JuMP
using HiGHS
# using Plots

function day01()
    part = [0, 0]
    position, newstart = 50, 50
    for line in filter(!isempty, split(read("day01.txt", String), '\n'))
        if line[begin] == 'R' # right, clockwise, positive
            newstart = position + parse(Int, line[2:end])
            part[2] += newstart ÷ 100
        else # left, negative
            newstart = position - parse(Int, line[2:end])
            if newstart <= 0
                part[2] += -newstart ÷ 100 + (position > 0)
            end
        end
        position = mod(newstart, 100)
        if position == 0
            part[1] += 1
        end
    end
    return part
end

function day02()
    part = [0, 0]
    dig = zeros(Int, 12)
    for range in split(read("day02.txt", String), ',')
        start, stop = parse.(Int, split(range, '-'))
        for i in start:stop
            ndig = ndigits(i)
            half = ndig ÷ 2
            digits!(dig, i)
            for span in 1:half
                ndig % span != 0 && continue
                if all(dig[j] == dig[k] for j in 1:span for k in (j+span):span:ndig)
                    part[2] += i
                    if span == half && iseven(ndig)
                        part[1] += i
                    end
                    break
                end
            end
        end
    end
    return part
end

function day03()
    part = [0, 0]
    lines = split(read("day03.txt", String), '\n')
    bdigits = [parse.(Int, collect(line)) for line in lines if !isempty(line)]

    for row in bdigits
        d1, dipos = findmax(@view row[begin:(end-1)])
        d2 = maximum(@view row[(dipos+1):end])
        part[1] += 10 * d1 + d2
    end

    for row in bdigits
        joltage, pos = 0, 1
        for battery in 1:12
            d, newpos = findmax(@view row[pos:(end-12+battery)])
            joltage = joltage * 10 + d
            pos += newpos
        end
        part[2] += joltage
    end

    return part # [17408, 172740584266849]
end

function day04()
    part = [0, 0]
    mat = stack([[c == '@' for c in collect(line)] for line in readlines("day04.txt")], dims = 1)
    nrows, ncols = size(mat)
    mat = vcat(zeros(Bool, ncols)', mat, zeros(Bool, ncols)') # wrap rows with 0
    mat = hcat(zeros(Bool, nrows + 2), mat, zeros(Bool, nrows + 2)) # wrap cols with 0
    nrows, ncols = size(mat)
    removable = Vector{Int}[]
    for step in 1:length(mat)
        for y in 2:(ncols-1)
            for x in 2:(nrows-1)
                !mat[x, y] && continue
                neighborrolls = 0
                if mat[x-1, y-1]
                    neighborrolls += 1
                end
                if mat[x-1, y+1]
                    neighborrolls += 1
                end
                if mat[x-1, y]
                    neighborrolls += 1
                end
                if mat[x+1, y-1]
                    neighborrolls += 1
                end
                if mat[x+1, y+1]
                    neighborrolls += 1
                end
                if mat[x+1, y]
                    neighborrolls += 1
                end
                if mat[x, y-1]
                    neighborrolls += 1
                end
                if mat[x, y+1]
                    neighborrolls += 1
                end
                if neighborrolls < 4
                    if step == 1
                        part[1] += 1
                    end
                    push!(removable, [x, y])
                end
            end
        end
        isempty(removable) && break
        for (x, y) in removable
            mat[x, y] = 0
            part[2] += 1
        end
        empty!(removable)
    end
    return part # [1626, 9173]
end

function day05()
    part = [0, 0]
    ranges = UnitRange{Int}[]
    combined = UnitRange{Int}[]

    for line in eachline("day05.txt")
        if contains(line, '-')
            start, stop = parse.(Int, split(line, '-'))
            push!(ranges, start:stop)
        elseif isempty(line) && isempty(combined)
            sort!(ranges, by = first)
            start = first(ranges[1])
            stop = last(ranges[1])
            for r in Iterators.drop(ranges, 1)
                if first(r) <= stop + 1
                    stop = max(stop, last(r))
                else
                    push!(combined, start:stop)
                    start = first(r)
                    stop = last(r)
                end
            end
            push!(combined, start:stop)
            part[2] = sum(length, combined)
        else
            num = parse(Int, line)
            for r in combined
                if num in r
                    part[1] += 1
                    break
                end
            end
        end
    end

    return part # [615, 353716783056994]
end

function day06()
    part = [0, 0]
    text = read("day06.txt", String)
    lines = split(text, '\n'; keepempty = false)

    lastline = collect(lines[end])
    operators = [c == '+' ? sum : prod for c in lastline if !isspace(c)]
    nrows, ncols = length(lines) - 1, length(operators)
    part1mat = Array{Int}(undef, nrows, ncols)
    for (i, line) in enumerate(lines[begin:(end-1)])
        part1mat[i, :] = parse.(Int, split(line, r"\s+", keepempty = false))
    end
    part[1] = sum(f(part1mat[:, i]) for (i, f) in enumerate(operators))

    chars = stack([collect(line) for line in lines], dims = 1)
    part2mat = Char.(rotl90(UInt32.(chars)))
    nrows = size(part2mat, 1)
    numbers = Int[]
    for row in 1:nrows
        op = findfirst(c -> c == '+' || c == '*', part2mat[row, :])
        txt = isnothing(op) ? strip(join(part2mat[row, :])) : strip(join(part2mat[row, begin:(op-1)]))
        !isempty(txt) && push!(numbers, parse(Int, txt))
        if !isnothing(op)
            part[2] += part2mat[row, op] == '+' ? sum(numbers) : prod(numbers)
            empty!(numbers)
        end
    end

    return part # [5877594983578, 11159825706149]
end

function day07()
    part = [0, 0]
    mat = stack([collect(line) for line in readlines("day07.txt")], dims = 1)
    nrows, ncols = size(mat)

    startpos = findfirst(x -> x == 'S', mat)
    mat[startpos] = '|'
    countmat = zeros(Int, nrows, ncols)
    countmat[startpos] = 1
    for x in 1:(nrows-1)
        for y in 1:ncols
            if mat[x, y] == '|'
                if mat[x+1, y] == '^'
                    if y > 1
                        mat[x+1, y-1] = '|'
                        countmat[x+1, y-1] += countmat[x, y]
                    end
                    if y < ncols
                        mat[x+1, y+1] = '|'
                        countmat[x+1, y+1] += countmat[x, y]
                    end
                    part[1] += 1
                else
                    mat[x+1, y] = '|'
                    countmat[x+1, y] += countmat[x, y]
                end
            end
        end
    end
    part[2] = sum(countmat[nrows, :])

    return part # [1605, 29893386035180]
end

function day08()
    part = [0, 0]
    boxes = [parse.(Int, split(line, ',')) for line in eachline("day08.txt")]
    nboxes = length(boxes)
    distances = Pair{Tuple{Int, Int}, Int}[]
    for b1 in 1:(nboxes-1)
        for b2 in (b1+1):nboxes
            dist = sum(((boxes[b1] .- boxes[b2]) .^ 2)) # euclidean distance ^ 2
            push!(distances, (b1, b2) => dist)
        end
    end
    sort!(distances, by = last)
    used = BitSet()
    circuits = BitSet[]

    for (connection, ((a, b), _)) in enumerate(distances)
        if a ∈ used && b ∈ used
            ca = findfirst(c -> a ∈ c, circuits)
            cb = findfirst(c -> b ∈ c, circuits)
            if ca != cb
                # merge circuits
                if length(ca) < length(cb)
                    ca, cb = cb, ca # ensure ca is larger for efficiency
                end
                union!(circuits[ca], circuits[cb])
                circuits[cb], circuits[end] = circuits[end], circuits[cb]
                pop!(circuits) # swap and pop
                if length(circuits) == 1 && length(circuits[begin]) == nboxes
                    part[2] = boxes[a][begin] * boxes[b][begin] # done at this point
                    break
                end
            end
        elseif a ∈ used
            # add to circuit containing a
            push!(circuits[findfirst(c -> a ∈ c, circuits)], b)
        elseif b ∈ used
            # add to circuit containing b
            push!(circuits[findfirst(c -> b ∈ c, circuits)], a)
        else # make new circuit
            push!(circuits, Set([a, b]))
        end
        push!(used, a, b) # mark a and b as used
        if connection == 1000 # multiply lengths of 3 largest circuits at step 1000
            sort!(circuits, by = length, rev = true)
            part[1] = prod(length, circuits[begin:(begin+2)])
        end
    end

    return part # [50760, 3206508875]
end


function day09()
    part = [0, 0]
    redtiles = [parse.(Int, split(line, ",")) for line in readlines("day09.txt")]
    ntiles = length(redtiles)
    minx, maxx = extrema(first.(redtiles))
    miny, maxy = extrema(last.(redtiles))
    for tile in redtiles
        tile[1] -= minx - 1
        tile[2] -= miny - 1
    end
    areas = sort!(
        [
            ((abs(redtiles[i][1] - redtiles[j][1]) + 1) *
             (abs(redtiles[i][2] - redtiles[j][2]) + 1) => (i, j))
            for i in 1:(ntiles-1) for j in (i+1):ntiles
        ], rev = true, by = first)
    part[1] = areas[begin][1]

    lowerright = ntiles ÷ 2 + 1 # lower right corner of rectangle
    quarterway = ntiles ÷ 4
    lrx, lry = redtiles[lowerright]
    lastupperright = findlast(k -> redtiles[k][1] >= lrx, 1:(quarterway-1)) + 1
    urx, ury = redtiles[lastupperright]
    upperleft = findfirst(j -> quarterway + 1 < j < lowerright - 1 &&
                               ury >= redtiles[j][2], 1:ntiles) + 1
    ulx, uly = redtiles[upperleft]
    @assert all(redtiles[j][2] >= uly || redtiles[j][1] >= lrx for j in 1:quarterway)
    candidate = findfirst(a -> a[2][1] == upperleft && a[2][2] == lowerright, areas)
    part[2] = areas[candidate][1]
    #=
    This had to be solved graphically: the solving procedure with plotting is as below.

    vertices = [(r[1], r[2]) for r in redtiles]
    p = plot(vertices, legend = false)

    upperarea = areas[candidate][1]
    upperright = lowerright + 1
    urx2, ury2 = redtiles[upperright]
    lastlowerright = findfirst(k -> 3 * quarterway < k < ntiles &&
       redtiles[k][1] >= urx2, 1:ntiles) - 1
    lrx2, lry2 = redtiles[lastlowerright]
    lowerleft = findlast(j -> upperright < j < 3 * quarterway &&
       lry2 <= redtiles[j][2], 1:ntiles)
    llx2, lly2 = redtiles[lowerleft]
    @assert all(redtiles[k][2] < lry2 || redtiles[k][1] >= lrx2 for k in quarterway*3:ntiles)
    candidate2 = findfirst(a -> a[2][1] == upperright && a[2][2] == lowerleft, areas)
    lowerarea = areas[candidate2][1]
    part[2] = max(upperarea, lowerarea)
      scatter!(p, (lrx, lry), markershape = :star5, markersize = 5, color = :green)
        plot!(p, [(lrx, lry), (urx, ury), (ulx, uly), (ulx, lry)], color = :gold)
        scatter!(p, (ulx, uly), markershape = :star5, markersize = 5, color = :red)
        scatter!(p, (urx2, ury2), markershape = :star5, markersize = 5, color = :yellow)
        scatter!(p, (llx2, lly2), markershape = :star5, markersize = 5, color = :aquamarine)
        plot!(p, [(urx2, ury2), (lrx2, lry2), (llx2, lly2), (llx2, ury2)], color = :gold)
        display(p)

    =#
    return part # [4735268538, 1537458069]
end

function day10()
    part = [0, 0]
    lights, buttons, joltage = Vector{Bool}[], Vector{Vector{Int}}[], Vector{Int}[] # nb: data is zero-based
    for line in readlines("day10.txt")
        txt = split(line, " ")
        push!(lights, [ch == '#' for ch in popfirst!(txt)[(begin+1):(end-1)]])
        push!(joltage, parse.(Int, split((pop!(txt))[(begin+1):(end-1)], ',')))
        push!(buttons, [[parse(Int, s) for s in split(t[(begin+1):(end-1)], ",")] for t in txt])
    end
    nmachines = length(lights)

    for i in 1:nmachines
        states = [falses(length(lights[i]))]
        newstates = Vector{Vector{Bool}}()
        for press in 1:1000
            for current in states
                for b in buttons[i]
                    newstate = copy(current)
                    for pos in b
                        newstate[pos+1] = !newstate[pos+1]
                    end
                    if newstate == lights[i]
                        part[1] += press
                        @goto FOUND
                    end
                    push!(newstates, newstate)
                end
            end
            states = unique(newstates)
            empty!(newstates)
        end
        @label FOUND
    end

    # linear optimization approach for part 2
    nbuttons = maximum(length, buttons)
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    @variable(model, pressed[1:nbuttons] >= 0, Int)
    @objective(model, Min, sum(pressed))
    for i in 1:nmachines
        goal = joltage[i]
        njolts = length(goal)
        nbuttons = length(buttons[i])
        bmat = zeros(Bool, njolts, nbuttons)
        for j in 1:njolts
            for k in 1:nbuttons
                if j - 1 in buttons[i][k]
                    bmat[j, k] = 1
                end
            end
        end
        constraints = [@constraint(model, sum(pressed[1:nbuttons] .* bmat[j, :]) == goal[j]) for j in 1:njolts]
        optimize!(model)
        part[2] += objective_value(model)
        delete.(model, constraints)
    end

    return part # [469, 19293]
end

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

function day12()
    part = [0, 0]
    shapeareas = Int[]
    shapetext = split(read("day12.txt", String), "\n\n")
    for shapelines in shapetext[begin:(end-1)]
        lines = split(shapelines, "\n", keepempty = false)
        popfirst!(lines) # remove label
        shape = stack([c == '#' for c in collect(line)] for line in lines)
        push!(shapeareas, sum(shape))
    end
    for line in split(shapetext[end], "\n", keepempty = false)
        nums = parse.(Int, split(line, r"[x\s:]+"))
        rectanglearea = popfirst!(nums) * popfirst!(nums)
        totalshapearea = sum(shapeareas[i] * nums[i] for i in eachindex(nums))
        if totalshapearea <= rectanglearea
            part[1] += 1
        end
    end
    return part # [497, 0]
end

function time2025()
    tsum = 0.0
    println(" Day     Seconds\n=================")
    for f in [day01, day02, day03, day04, day05, day06, day07, day08, day09, day10, day11, day12]
        t = @belapsed $f()
        println(f, "   ", t)
        tsum += t
    end
    println("=================\nTotal   ", tsum)
end

time2025()

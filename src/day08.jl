using BenchmarkTools

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

@btime day08()
@show day08()

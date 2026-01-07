const NODE_COUNT11 = 577
const DEVICES11 = ["" for _ in 1:NODE_COUNT11]
const MAT11 = falses(NODE_COUNT11, NODE_COUNT11)
const PATHCOUNT11 = fill(-1, NODE_COUNT11, NODE_COUNT11)
const VISITED11 = falses(NODE_COUNT11)

""" memoized recursive DFS function to count paths from current to target """
function count11paths(current::Int, target::Int)::Int
    current == target && return 1
    if PATHCOUNT11[current, target] != -1
        return PATHCOUNT11[current, target]
    end
    total = 0
    for i in 1:NODE_COUNT11
        if MAT11[current, i] && !VISITED11[i]
            VISITED11[i] = true
            total += count11paths(i, target)
            VISITED11[i] = false
        end
    end
    PATHCOUNT11[current, target] = total
    if total > 0
        PATHCOUNT11[target, current] = 0
    end
    return total
end

function day11()
    part = [0, 0]
    nc = 0
    DEVICES11 .= ""
    for line in eachline("day11.txt")
        nodes = split(line, r"[\s:]+")
        parent = 0
        for (i, name) in enumerate(nodes)
            nodeidx = findfirst(==(name), DEVICES11)
            if nodeidx === nothing
                nc += 1
                DEVICES11[nc] = name
                nodeidx = nc
            end
            if i == 1
                parent = nodeidx
            else
                MAT11[parent, nodeidx] = true
            end
        end
    end
    @assert nc == NODE_COUNT11
    svr, out, you, dac, fft = map(s -> findfirst(==(s), DEVICES11), ["svr", "out", "you", "dac", "fft"])
    part[1] = count11paths(you, out)
    part[2] = count11paths(svr, fft) * count11paths(fft, dac) * count11paths(dac, out)
    return part # [607, 506264456238938]
end

@show day11()

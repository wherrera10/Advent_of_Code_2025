using BenchmarkTools

function day12()
    part = [0, 0]
    shapeareas = Int[]
    shapetext = split(read("day12.txt", String), "\n\n")
    for shapelines in shapetext[begin:end-1]
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

@btime day12()
@show day12()

using BenchmarkTools
using JuMP
using HiGHS

function day10()
    part = [0, 0]
    lights, buttons, joltage = Vector{Bool}[], Vector{Vector{Int}}[], Vector{Int}[] # nb: data is zero-based
    for line in readlines("day10.txt")
        txt = split(line, " ")
        push!(lights, [ch == '#' for ch in popfirst!(txt)[begin+1:end-1]])
        push!(joltage, parse.(Int, split((pop!(txt))[begin+1:end-1], ',')))
        push!(buttons, [[parse(Int, s) for s in split(t[begin+1:end-1], ",")] for t in txt])
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

@btime day10()
@show day10()

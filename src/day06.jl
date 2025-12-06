using BenchmarkTools

using LinearAlgebra

function day06()
    part = [0, 0]
    text = read("day06.txt", String)
    lines = split(text, '\n'; keepempty = false)
    lastline = collect(lines[end])
    operators = [c == '+' ? sum : prod for c in lastline if !isspace(c)]
    nrows, ncols = length(lines)-1, length(operators)
    part1mat = Array{Int}(undef, nrows, ncols)
    for (i, line) in enumerate(lines[begin:(end-1)])
        ntexts = split(line, r"\s+", keepempty = false)
        part1mat[i, :] = parse.(Int, ntexts)
    end
    for (i, f) in enumerate(operators)
        part[1] += f(part1mat[:, i])
    end

    chars = stack([collect(line) for line in lines], dims = 1)
    part2mat = Char.(rotl90(UInt32.(chars)))
    nrows, ncols = size(part2mat)
    numbers = Int[]
    for row in 1:nrows
        op = findfirst(c -> c == '+' || c == '*', part2mat[row, :])
        txt = isnothing(op) ? strip(join(part2mat[row, :])) : strip(join(part2mat[row, begin:(op-1)]))
        !isempty(txt) && push!(numbers, parse(Int, txt))
        if !isnothing(op)
            if part2mat[row, op] == '+'
                part[2] += sum(numbers)
            elseif part2mat[row, op] == '*'
                part[2] += prod(numbers)
            end
            empty!(numbers)
        end
    end


    return part # [5877594983578, 11159825706149]
end

@btime day06()
@show day06()

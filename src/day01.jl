# Advent of Code 2025, Day 1

using BenchmarkTools

function day01()
    part = [0, 0]
    position = 50  # starting at position 50
    for line in eachline("day01.txt")
        clicks = parse(Int, line[begin+1:end])
        if line[1] == 'R' # positive direction, clockwise
            part[2] += (position + clicks) ÷ 100
        else
            part[2] += ((100 - position) % 100 + clicks) ÷ 100
            clicks *= -1
        end # counterclockwise, negative direction
        position = (position + clicks) % 100
        if position == 0
            part[1] += 1
        end
    end
    return part
end

@btime day01()
@show day01() # [1029, 5892]

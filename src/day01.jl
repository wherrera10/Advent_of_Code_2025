# Advent of Code 2025, Day 1

function day01()
    part = [0, 0]
    start = 50
    for line in eachline("day01.txt")
        newstart = start + (line[1] == 'R' ? 1 : -1) * parse(Int, line[2:end])
        if newstart > 99
            part[2] += newstart ÷ 100
        elseif newstart <= 0
            part[2] += -newstart ÷ 100 + (start > 0)
        end
        start = (((newstart) % 100) + 100) % 100
        if start == 0
            part[1] += 1
        end
    end
    return part
end

@show day01()

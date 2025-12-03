using BenchmarkTools

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
    return part #  [1029, 5892]
end

@btime day01()
@show day01()

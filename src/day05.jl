using BenchmarkTools

function day05()
    part = [0, 0]
    ranges = UnitRange{Int}[]
    combined = UnitRange{Int}[]

    for line in eachline("day05.txt")
        if contains(line, '-')
            start, stop = parse.(Int, split(line, '-'))
            push!(ranges, start:stop)
        elseif isempty(line) && isempty(combined)
            sortedranges = sort(ranges, by = r -> first(r))
            start = first(sortedranges[1])
            stop = last(sortedranges[1])
            for r in Iterators.drop(sortedranges, 1)
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

@btime day05()
@show day05()

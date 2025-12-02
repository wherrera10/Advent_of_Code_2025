# Advent of Code 2025, Day 2

using BenchmarkTools

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
                if all(dig[j] == dig[k] for j in 1:span for k in j+span:span:ndig)
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

@btime day02()
@show day02()

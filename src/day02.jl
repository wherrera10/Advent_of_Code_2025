using BenchmarkTools

const DAY2_1 = [[2, 1], [4, 2], [6, 3], [8, 4], [10, 5]]
const DAY2_2 = [[3, 1], [5, 1], [6, 2], [7, 1], [9, 3], [10, 2]]
const DAY2DUPS = [[6, 1], [10, 1]]
const POW10 = [10^i for i in 0:12]

"""
Sum the number of values contained in the given id range for each type of grouping.
"""
function badidcount02(groupings, inputranges)
    result = 0
    for (rlen, glen) in groupings
        interval  = (POW10[rlen + 1] - 1) ÷ (POW10[glen + 1] - 1)
        for (rstart, rstop) in inputranges
            lower = cld(max(rstart, POW10[rlen]), interval)
            upper = min(rstop, POW10[rlen + 1]) ÷ interval
            if lower ≤ upper
                result +=  interval * (upper^2 - lower^2 + lower + upper) ÷ 2
            end
        end
    end
    return result
end

function day02()
    part = [0, 0]
    nums = [parse(Int, s.match) for s in eachmatch(r"\d+", read("day02.txt", String))]
    ranges = [[nums[i], nums[i+1]] for i in 1:2:length(nums)]
    part[1] = badidcount02(DAY2_1, ranges)
    part[2] = part[1] + badidcount02(DAY2_2, ranges) - badidcount02(DAY2DUPS, ranges)
    return part
end

@btime day02()
@show day02()

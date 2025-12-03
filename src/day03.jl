# Advent of Code 2025, Day 3

using BenchmarkTools

function day03()
	part = [0, 0]
	lines = split(read("day03.txt", String), '\n')
	digits = [parse.(Int, collect(line)) for line in lines if !isempty(line)]

	for row in digits
		d1, dipos = findmax(row[begin:(end-1)])
		d2 = maximum(row[(dipos+1):end])
		part[1] += 10 * d1 + d2
	end

	for row in digits
		joltage, pos = 0, 1
		for battery in 1:12
			d, newpos = findmax(row[pos:(end-12+battery)])
			joltage = joltage * 10 + d
			pos += newpos
		end
		part[2] += joltage
	end

	return part # [17408, 172740584266849]
end

@btime day03()
@show day03()

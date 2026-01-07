using Combinatorics

@memoize function dfs10(localgoal, patterncosts)::Int
	all(i == 0 for i in localgoal) && return 0
	answer = 1000000
	parity = localgoal .% 2
    for (pattern, pcost) in patterncosts[parity]
        if all(p <= g for (p, g) in zip(pattern, localgoal))
            newgoal = (localgoal .- pattern) .÷ 2
            answer = min(answer, pcost + 2 * dfs10(newgoal, patterncosts))
        end
    end
	return answer
end

function patterns10(problemvec::Vector{Vector{Int}})::Dict{Vector{Int}, Dict{Vector{Int}, Int}}
	nbuttons = length(problemvec)
	nvariables = length(problemvec[begin])
	result = Dict(digits(n, base=2, pad=nvariables) => Dict{Vector{Int}, Int}()
	   for n in 0:(2^nvariables - 1))
	for npressed in 0:nbuttons
		for buttons in combinations(0:(nbuttons-1), npressed)
			pattern = zeros(Int, nvariables)
			for i in buttons
				pattern .+= problemvec[i+1]
			end
			paritypattern = pattern .% 2
			if !haskey(result[paritypattern], pattern)
				result[paritypattern][pattern] = npressed
			end
		end
	end
	return result
end

function day10()
	part = [0, 0]
	lights, buttons, joltage = Vector{Bool}[], Vector{Vector{Int}}[], Vector{Int}[] # nb: data is zero-based
	for line in readlines("day10.txt")
		txt = split(line, " ")
		push!(lights, [ch == '#' for ch in popfirst!(txt)[(begin+1):(end-1)]])
		push!(joltage, parse.(Int, split((pop!(txt))[(begin+1):(end-1)], ',')))
		push!(buttons, [[parse(Int, s) for s in split(t[(begin+1):(end-1)], ",")] for t in txt])
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
		problemvec = Vector{Vector{Int}}()
		for r in buttons[i]
			row = [Int(k - 1 ∈ r) for k in eachindex(joltage[i])]
			push!(problemvec, row)
		end
		subscore = dfs10(joltage[i], patterns10(problemvec))
		part[2] += subscore
	end
	return part # [469, 19293]
end

@show day10()

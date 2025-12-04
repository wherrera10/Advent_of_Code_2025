using BenchmarkTools

function day04()
	part = [0, 0]
	mat = stack([[c == '@' for c in collect(line)] for line in readlines("day04.txt")], dims = 1)
	nrows, ncols = size(mat)
	mat = vcat(zeros(Bool, ncols)', mat, zeros(Bool, ncols)') # wrap rows with 0
	mat = hcat(zeros(Bool, nrows+2), mat, zeros(Bool, nrows+2)) # wrap cols with 0
	nrows, ncols = size(mat)
	removable = Vector{Int}[]
	for step in 1:length(mat)
		for y in 2:ncols-1
			for x in 2:nrows-1
				!mat[x, y] && continue
				neighborrolls = 0
    			if mat[x-1, y-1]
					neighborrolls += 1
				end
				if mat[x-1, y+1]
					neighborrolls += 1
				end
				if mat[x-1, y]
					neighborrolls += 1
				end
				if mat[x+1, y-1]
					neighborrolls += 1
				end
				if mat[x+1, y+1]
					neighborrolls += 1
				end
				if mat[x+1, y]
					neighborrolls += 1
				end
				if mat[x, y-1]
					neighborrolls += 1
				end
				if mat[x, y+1]
					neighborrolls += 1
				end
				if neighborrolls < 4
					if step == 1
						part[1] += 1
					end
					push!(removable, [x, y])
				end
			end
		end
		isempty(removable) && break
		for (x, y) in removable
			mat[x, y] = 0
			part[2] += 1
		end
		empty!(removable)
	end
	return part # [1626, 9173]
end

@btime day04()
@show day04()

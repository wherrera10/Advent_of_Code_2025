using BenchmarkTools

function day04()
	part = [0, 0]
	mat = stack([collect(line) for line in readlines("day04.txt")], dims = 1)
	nrows, ncols = size(mat)
	removable = Vector{Int}[]
	for step in 1:length(mat)
		for y in 1:ncols
			for x in 1:nrows
				mat[x, y] != '@' && continue
				neighborrolls = 0
				if x > 1
					if y > 1
						if mat[x-1, y-1] == '@'
							neighborrolls += 1
						end
					end
					if y < ncols
						if mat[x-1, y+1] == '@'
							neighborrolls += 1
						end
					end
					if mat[x-1, y] == '@'
						neighborrolls += 1
					end
				end
				if x < nrows
					if y > 1
						if mat[x+1, y-1] == '@'
							neighborrolls += 1
						end
					end
					if y < ncols
						if mat[x+1, y+1] == '@'
							neighborrolls += 1
						end
					end
					if mat[x+1, y] == '@'
						neighborrolls += 1
					end
				end
				if y > 1
					if mat[x, y-1] == '@'
						neighborrolls += 1
					end
				end
				if y < ncols
					if mat[x, y+1] == '@'
						neighborrolls += 1
					end
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
			mat[x, y] = '.'
			part[2] += 1
		end
		empty!(removable)
	end
	return part # [1626, 9173]
end

@btime day04()
@show day04()

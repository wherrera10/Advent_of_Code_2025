using LinearAlgebra
using Plots

function day07()
    part = [0, 0]
    mat = stack([collect(line) for line in readlines("day07.txt")], dims = 1)
    nrows, ncols = size(mat)
    @show nrows ncols
    startpos = findfirst(x -> x == 'S', mat)
    mat[startpos] = '|'
    countmat = zeros(Int, nrows, ncols)
    countmat[startpos] = 1
    for x in 1:(nrows-1)
        for y in 1:ncols
            if mat[x, y] == '|'
                if mat[x+1, y] == '^'
                    if y > 1
                        mat[x+1, y-1] = '|'
                        countmat[x+1, y-1] += countmat[x, y]
                    end
                    if y < ncols
                        mat[x+1, y+1] = '|'
                        countmat[x+1, y+1] += countmat[x, y]
                    end
                    part[1] += 1
                else
                    mat[x+1, y] = '|'
                    countmat[x+1, y] += countmat[x, y]
                end
            end
        end
    end

    display(heatmap(log.(rot180(countmat) .+ 1), axis = false, title = "Heatmap of Log Timelines", colormap = :viridis))

    part[2] = sum(countmat[nrows, :])
    return part # [1605, 29893386035180]
end

@show day07()

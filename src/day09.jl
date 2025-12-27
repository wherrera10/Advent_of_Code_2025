using BenchmarkTools
using Plots

function day09()
    part = [0, 0]
    redtiles = [parse.(Int, split(line, ",")) for line in readlines("day09.txt")]
    ntiles = length(redtiles)
    minx, maxx = extrema(first.(redtiles))
    miny, maxy = extrema(last.(redtiles))
    for tile in redtiles
        tile[1] -= minx - 1
        tile[2] -= miny - 1
    end
    areas = sort!(
        [
            ((abs(redtiles[i][1] - redtiles[j][1]) + 1) *
             (abs(redtiles[i][2] - redtiles[j][2]) + 1) => (i, j))
            for i in 1:(ntiles-1) for j in (i+1):ntiles
        ], rev = true, by = first)
    part[1] = areas[begin][1]


    lowerright = ntiles ÷ 2 + 1 # lower right corner of rectangle
    quarterway = ntiles ÷ 4
    lrx, lry = redtiles[lowerright]
    lastupperright = findlast(k -> redtiles[k][1] >= lrx, 1:(quarterway-1)) + 1
    urx, ury = redtiles[lastupperright]
    upperleft = findfirst(j -> quarterway + 1 < j < lowerright - 1 &&
                               ury >= redtiles[j][2], 1:ntiles) + 1
    ulx, uly = redtiles[upperleft]
    @assert all(redtiles[j][2] >= uly || redtiles[j][1] >= lrx for j in 1:quarterway)
    candidate = findfirst(a -> a[2][1] == upperleft && a[2][2] == lowerright, areas)
    part[2] = areas[candidate][1]
    
    #=
    This had to be solved graphically: the solving procedure with plotting is as below.

    upperarea = areas[candidate][1]
    upperright = lowerright + 1
    urx2, ury2 = redtiles[upperright]
    lastlowerright = findfirst(k -> 3 * quarterway < k < ntiles &&
       redtiles[k][1] >= urx2, 1:ntiles) - 1
    lrx2, lry2 = redtiles[lastlowerright]
    lowerleft = findlast(j -> upperright < j < 3 * quarterway &&
       lry2 <= redtiles[j][2], 1:ntiles)
    llx2, lly2 = redtiles[lowerleft]
    @assert all(redtiles[k][2] < lry2 || redtiles[k][1] >= lrx2 for k in quarterway*3:ntiles)
    candidate2 = findfirst(a -> a[2][1] == upperright && a[2][2] == lowerleft, areas)
    lowerarea = areas[candidate2][1]
    part[2] = max(upperarea, lowerarea)
    
    vertices = [(r[1], r[2]) for r in redtiles]
    p = plot(vertices, legend = false)
    scatter!(p, (lrx, lry), markershape = :star5, markersize = 5, color = :green)
    plot!(p, [(lrx, lry), (urx, ury), (ulx, uly), (ulx, lry)], color = :gold)
    scatter!(p, (ulx, uly), markershape = :star5, markersize = 5, color = :red)
    scatter!(p, (urx2, ury2), markershape = :star5, markersize = 5, color = :yellow)
    scatter!(p, (llx2, lly2), markershape = :star5, markersize = 5, color = :aquamarine)
    plot!(p, [(urx2, ury2), (lrx2, lry2), (llx2, lly2), (llx2, ury2)], color = :gold)
    display(p)
    =#

    return part # [4735268538, 1537458069]
end

@btime day09()
@show day09()

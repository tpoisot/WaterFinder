# Function to get the features for each grid
function getfeatures(grid)
  r = map((x) -> x.r, grid)
  g = map((x) -> x.g, grid)
  b = map((x) -> x.b, grid)
  return vec([mean(r), mean(g), mean(b), median(r), median(g), median(b)])
end

# Most common elements
function most_common(x::Array)
    # NOTE this is ugly but it works
    c = unique(x)
    f = zeros(Int64, length(c))
    for t in x
        for u in 1:length(c)
            if t == c[u]
                f[u] = f[u]+1
            end
        end
    end
    # Return
    for i in 1:length(c)
        if f[i] == maximum(f)
            return c[i]
        end
    end
end

# Euclidean distance
function distance(x, y)
    return sqrt(sum((x .- y).^2.0))
end

# Read input
function input()
  return chomp(readline())
end

# Problem to classify
function classify(i, f, t, l; k = 5)
  pb = f[i]
  # We get the distances
  dist = map(x -> distance(pb, x), f[t]);
  # Labels of the closest neighbors
  candidates = l[filter(x -> dist[x] <= sort(dist)[k], 1:length(dist))];
  # Return
  assignation = most_common(candidates);
  return assignation
end

# Split an image
function imgsplit(img; grids=50)
  imgsize = size(img);
  # Get the splits
  alongx = 1:gridsize:imgsize[1]-gridsize;
  alongy = 1:gridsize:imgsize[2]-gridsize;

  # Empty array to store the images
  samples = Array{Any, 2}((length(alongx), length(alongy)))
  for i in eachindex(alongx)
    for j in eachindex(alongy)
      # We extract the image and put it in an array
      timg = img[x:x+gridsize, y:y+gridsize]
      push!(samples, timg)
    end
  end
  # Return
  return samples
end

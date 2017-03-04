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
function classify(i, features, training, labels; k = 5)
  # We get the distances
  dist = map(x -> distance(features[i], x), features[training]);
  # Labels of the closest neighbors
  candidates = labels[training[filter(x -> dist[x] <= sort(dist)[k], 1:length(dist))]]
  # Return
  assignation = most_common(candidates);
  return assignation
end

# Split an image
function imgsplit(img; gridsize=50)
  imgsize = size(img);
  # Get the splits
  x = 1:gridsize:imgsize[1]-gridsize;
  y = 1:gridsize:imgsize[2]-gridsize;

  # Empty array to store the images
  samples = Array{Any, 2}((length(x), length(y)))
  for i in eachindex(x)
    for j in eachindex(y)
      # We extract the image and put it in an array
      samples[i,j] = img[x[i]:x[i]+gridsize, y[j]:y[j]+gridsize]
    end
  end
  # Return
  return samples
end

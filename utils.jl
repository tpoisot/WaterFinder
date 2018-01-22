# Function to get the features for each grid
function getfeatures(grid)
  r = map((x) -> x.r, grid)
  g = map((x) -> x.g, grid)
  b = map((x) -> x.b, grid)
  return vec([
    mean(r), mean(g), mean(b),
    median(r), median(g), median(b),
    var(r), var(g), var(b)
  ])
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

# Problem to classify
function knn(instance, training; k = 5)
  # We get the distances
  labels = map(x -> x[2], training)
  dist = map(x -> distance(instance, x[1]), training)
  # Labels of the closest neighbors
  candidates = labels[filter(x -> dist[x] <= sort(dist)[k], 1:length(dist))]
  # Return
  assignation = most_common(candidates);
  return assignation
end

using ImageView, Images, FileIO;
using StatsBase;
using Luxor;
using Colors;
using Plots;

include("./utils.jl");

img = load("./img/train.png");
imshow(img)
tgsize = 25;
span = convert(Int64, floor(tgsize/2));

labels = Dict()

# TODO find a way to clik on the image
labels["forest"] = [(207,442),(455,479),(237,940),(187,279),(126,355),(190,767),(483,463),(635,795)]
labels["water"] = [(153, 13), (374,1035),(457,1033),(262,1022),(275,499),(168,578),(621,907)]
labels["road"] = [(383,486),(413,821),(484,791),(539,46),(330,901),(175,1038),(335,360)]
labels["field"] = [(478,817),(507,860),(603,116),(13,216),(508,906)]
labels["urban"] = [(306,179),(211,1019),(473,878),(403,507),(215,133),(142,195)]

training = Array{Tuple,1}()
for (k, v) in labels
  info(k)
  for point in v
    x,y = point
    xboundaries = x-span:x+span
    yboundaries = y-span:y+span
    push!(training, (getfeatures(img[xboundaries, yboundaries]), k))
  end
end

# Take a guess at every element in the other image
img2 = load("./img/test.png");
gsize = 10;

# We do k-means but with a moving window
L = unique(map(x -> x[2], training))
cons = Dict([x => zeros(Float64, size(img2)) for x in L])
cons["STD"] = zeros(Float64, size(img2))
for i in 1:5:(size(img2,1)-gsize)
  for j in 1:5:(size(img2,2)-gsize)
    sp = img2[i:(i+gsize-1),j:(j+gsize-1)]
    sf = getfeatures(sp)
    cl = knn(sf, training; k=3)
    cons[cl][i:(i+gsize-1),j:(j+gsize-1)] .+= 1
    cons["STD"][i:(i+gsize-1),j:(j+gsize-1)] .+= 1
  end
end

for l in L
  cons[l] = cons[l]./cons["STD"]
  cons[l][find(cons[l].==0)] .= 0.0
end

C = fill(0, size(img2))
for i in eachindex(C)
  if cons["STD"][i] > 0
    u = [cons[l][i] for l in L]
    m = find(x -> x.== maximum(u), u)[1]
    C[i] = m
  end
end

bg = readpng("./img/test.png")
w = bg.width
h = bg.height

begin
  Drawing(w, h)
  origin()
  placeimage(bg, -w/2, -h/2)
  for i in 1:size(C,1)
    for j in 1:size(C,2)
      xinit = (i-1)
      yinit = (j-1)
      setopacity(0.4)
      sethue(colorant"#999")
      if C[i,j] > 0
        if L[C[i,j]] == "water"
          sethue("blue")
        end
        if L[C[i,j]] == "forest"
          sethue("green")
        end
        if L[C[i,j]] == "urban"
          sethue("red")
        end
        if L[C[i,j]] == "field"
          sethue("purple")
        end
        if L[C[i,j]] == "road"
          sethue("orange")
        end
        rect(yinit-w/2, xinit-h/2, 1, 1, :fill)
      end
    end
  end
  finish()
  preview()
end

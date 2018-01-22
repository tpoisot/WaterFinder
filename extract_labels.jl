using ImageView, Images, FileIO;
using StatsBase;
using Luxor;
using Colors;
using Plots;

include("./utils.jl");

img = load("./img/test.png");
imshow(img)
tgsize = 25;
span = convert(Int64, floor(tgsize/2));

labels = Dict()

# TODO find a way to click on the image
labels["forest"] = [(190,1350),(406,928),(1118,1177),(125,1861),(690,2051),(246,1814),(963,1944)]
labels["water"] = [(877,822),(930,1822),(1108,700),(71,355),(55,520),(338,1065),(603,815),(912,1866),(874,1649)]
labels["built"] = [(402,1357),(494,586),(332,1813),(242,1031),(141,1600),(920,196),(702,121),(615,1134),(751,1489),(686,1657),(930,1994),(1097,1974),(654,186),(309,1761)]
labels["field"] = [(430,1661),(601,1367),(834,454),(101,972),(71,1956),(982,222)]

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
for i in 1:1:(size(img2,1)-gsize)
  for j in 1:1:(size(img2,2)-gsize)
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
        if L[C[i,j]] == "built"
          sethue("red")
        end
        if L[C[i,j]] == "field"
          sethue("purple")
        end
        rect(yinit-w/2, xinit-h/2, 1, 1, :fill)
      end
    end
  end
  finish()
  preview()
end

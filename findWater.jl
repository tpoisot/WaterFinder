using ImageView, Images, FileIO;
using StatsBase;
using Luxor;
using Colors;

include("./utils.jl");

img = load("./img/train.png");
tgsize = 25;

training_size = 50;
labels = Array{String, 1}(training_size);
positions = Array{Int64, 1}(training_size);
training_set = Vector{Array{Float64,1}}(training_size)
labelcounter = 1;
candicounter = 1;
while labelcounter <= training_size
  candicounter += 1
	fx, fy = size(img).-(3*tgsize, 3*tgsize)
	tx = sample((2*tgsize):fx)
	ty = sample((2*tgsize):fy)
  trial = img[(tx-2*tgsize):(tx+3*tgsize),(ty-2*tgsize):(ty+3*tgsize)]
  guidict = imshow(trial)
	annotate!(guidict, AnnotationBox(2*tgsize, 2*tgsize, 3*tgsize, 3*tgsize, linewidth=2))
  userinput = input()
  #destroy(toplevel(imc))
  ImageView.closeall()
  if userinput == "STOP"
    break
  elseif userinput == "SKIP"
    next
  else
    labels[labelcounter] = userinput
    positions[labelcounter] = candicounter
		training_set[labelcounter] = getfeatures(trial[(2*tgsize:3*tgsize),(2*tgsize:3*tgsize)])
    labelcounter += 1
  end
end

# Take a guess at every element in the other image

img2 = load("./img/test.png");
gsize = 10;

# We do k-means but with a moving window
L = unique(labels)
cons = Dict([x => zeros(Float64, size(img2)) for x in L])
cons["STD"] = zeros(Float64, size(img2))
for i in 1:5:(size(img2,1)-gsize)
  for j in 1:5:(size(img2,2)-gsize)
    sp = img2[i:(i+gsize-1),j:(j+gsize-1)]
    sf = getfeatures(sp)
    cl = classify(1, [sf], training_set, labels, k=3)
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
      setopacity(0.3)
      sethue(colorant"#999")
      if C[i,j] > 0
        if L[C[i,j]] == "W"
          sethue("blue")
        end
        if L[C[i,j]] == "R"
          sethue("red")
        end
        if L[C[i,j]] == "F"
          sethue("green")
        end
        if L[C[i,j]] == "U"
          sethue("black")
        end
        if L[C[i,j]] == "N"
          sethue("orange")
        end
        rect(yinit-w/2, xinit-h/2, 1, 1, :fill)
      end
    end
  end
  finish()
  preview()
end

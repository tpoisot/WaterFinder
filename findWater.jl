using ImageView, Images, FileIO;
using StatsBase;
using Luxor;
using Colors;

include("./utils.jl");

img = load("./img/train.png");
tgsize = 25;

training_size = 90;
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
		training_set[candicounter] = getfeatures(trial[(2*tgsize:3*tgsize),(2*tgsize:3*tgsize)])
    labelcounter += 1
  end
end

# Take a guess at every element in the other image

img2 = load("./img/test.png");
gsize = 5;
samples2 = imgsplit(img2, gridsize=gsize);
# Then we extract the features -- mean and median of every primary color
features2 = getfeatures.(samples2);

guesses = Array{String, 2}(size(samples2));
for i in eachindex(guesses)
  guesses[i] = classify(i, features2, training_set, labels, k=4)
end

bg = readpng("./img/test.png")
w = bg.width
h = bg.height

begin
  Drawing(w, h)
  origin()
  placeimage(bg, -w/2, -h/2)
  for i in 1:size(guesses,1)
    for j in 1:size(guesses,2)
      xinit = (i-1)*gsize
      yinit = (j-1)*gsize
      setopacity(0.6)
      sethue(colorant"#999")
      if guesses[i,j] == "W"
        sethue("blue")
      end
      if guesses[i,j] == "R"
        sethue("red")
      end
      if guesses[i,j] == "F"
        sethue("green")
      end
      if guesses[i,j] == "U"
        sethue("black")
      end
      if guesses[i,j] == "N"
        sethue("orange")
      end
      rect(yinit-w/2, xinit-h/2, gsize, gsize, :fill)
    end
  end
  finish()
  preview()
end

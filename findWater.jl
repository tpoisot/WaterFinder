using ImageView, Images, FileIO;
using StatsBase;
using Luxor;
using Colors;

include("./utils.jl");

img = load("./img/train.png");
samples = imgsplit(img, gridsize=25);

# Then we extract the features -- mean and median of every primary color
features = getfeatures.(samples);

# We will get some infos for the calibration dataset
training_candidates = sample(eachindex(samples), length(eachindex(samples)), replace=false);

traing_size = 90;
labels = Array{String, 1}(traing_size);
positions = Array{Int64, 1}(traing_size);
labelcounter = 1;
candicounter = 1;
while labelcounter <= traing_size
  i = training_candidates[candicounter]
  candicounter += 1
  trial = samples[i]
  imc, ims = imshow(trial)
  userinput = input()
  #destroy(toplevel(imc))
  ImageView.closeall()
  if userinput == "STOP"
    break
  elseif userinput == "SKIP"
    next
  else
    labels[labelcounter] = userinput
    positions[labelcounter] = i
    labelcounter += 1
  end
end

training_set = features[positions];

# Take a guess at every element in the other image

img2 = load("./img/test.png");
gsize = 20;
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
      setopacity(0.3)
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


for i in 1:size(guesses, 1)
  for j in 1:size(guesses, 2)
    if guesses[i,j][1] == 'W'
      print_with_color(:blue, "~")
    elseif guesses[i,j][1] == 'F'
      print_with_color(:green, "▒")
    elseif guesses[i,j][1] == 'R'
      print_with_color(:red, "█")
    else
      print("-")
    end
  end
  print("\n")
end

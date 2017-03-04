using ImageView, Images, FileIO;
using StatsBase;

include("./utils.jl");

img = load("./img/t1.png");
samples = imgsplit(img, gridsize=40);

# Then we extract the features -- mean and median of every primary color
features = getfeatures.(samples);

# We will get some infos for the calibration dataset
training_candidates = sample(eachindex(samples), length(eachindex(samples)), replace=false);

traing_size = 40;
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
  destroy(toplevel(imc))
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
samples2 = imgsplit(img2, gridsize=15);
# Then we extract the features -- mean and median of every primary color
features2 = getfeatures.(samples2);

guesses = Array{String, 2}(size(samples2));
for i in eachindex(guesses)
  guesses[i] = classify(i, features2, training_set, labels, k=4)
end

for i in 1:size(guesses, 1)
  for j in 1:size(guesses, 2)
    if guesses[i,j][1] == 'w'
      print_with_color(:blue, "░")
    elseif guesses[i,j][1] == 'g'
      print_with_color(:green, "▒")
    elseif guesses[i,j][1] == 'f'
      print_with_color(:red, "█")
    else
      print("-")
    end
  end
  print("\n")
end

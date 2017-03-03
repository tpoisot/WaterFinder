using ImageView, Images, FileIO;
using StatsBase;

include("./utils.jl");

img = load("./img/t1.png");
samples = imgsplit(img);

# Then we extract the features -- mean and median of every primary color
features = getfeatures.(samples);

# We will get some infos for the calibration dataset
training = sample(eachindex(samples), 15, replace=false);

labels = Array{String, 2}(size(samples));
for i in training
  trial = samples[i]
  imc, ims = imshow(trial)
  labels[i] = input()
  destroy(toplevel(imc))
  if labels[i] == "STOP"
    break
  end
end

# Take a guess at every element
guesses = Array{String, 2}(size(samples));
for i in eachindex(guesses)
  guesses[i] = classify(i, features, training, labels)
end

guesses

for i in 1:size(guesses, 1)
  for j in 1:size(guesses, 2)
    if guesses[i,j][1] == 'w'
      print_with_color(:blue, "~")
    elseif guesses[i,j][1] == 'g'
      print_with_color(:green, "w")
    elseif guesses[i,j][1] == 'f'
      print_with_color(:red, "@")
    else
      print("-")
    end
    print(" ")
  end
  print("\n")
end

using ImageView, Images, FileIO;
using StatsBase;
using Luxor;
using Colors;
using Plots;

img = load("./img/landscape.png");
tgsize = 35;

training_size = 200;

for split in 1:training_size
	fx, fy = size(img).-(2*tgsize, 2*tgsize)
	tx = sample((tgsize):fx)
	ty = sample((tgsize):fy)
  trial = img[(tx-tgsize):(tx),(ty-tgsize):(ty)]
  save("splits/train_"*string(split)*".jpg", trial)
end

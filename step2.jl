# Step 2

D = zeros(Float64, size(guesses))
for i in eachindex(D)
	if guesses[i] == "F"
		D[i] = 8.0
	end
	if guesses[i] == "W"
		D[i] = 0.001
	end
	if guesses[i] == "N"
		D[i] = 3.0
	end
	if guesses[i] == "U"
		D[i] = 0.01
	end
	if guesses[i] == "R"
		D[i] = 0.001
	end
end

V = zeros(Int64, size(D))
for re in 1:2000
	#x, y = sample(1:size(V,1)), sample(1:size(V,2))
	x, y, = 1, 1
	xD = copy(D)
	xV = zeros(Int64, size(D))
	for i in 1:5000
		xV[x,y] = xV[x,y]+1
		xD[x,y] = xD[x,y]*0.5
		xf, xt = x-1, x+1
		yf, yt = y-1, y+1
		xand = max(xf,1):min(xt,size(V,1))
		yand = max(yf,1):min(yt,size(V,2))
		tD = xD[xand,yand].+rand()*0.01
		keep = sample(eachindex(tD), weights(vec(tD)))
		ni = ind2sub(tD, keep)
		x, y = xand[ni[1]], yand[ni[2]]
		if ((100 < x < 120) & (165 < y < 185))
			V = V .+ xV
			info("#$re\thit after $i")
			break
		end
	end
end
# TODO convert index to tuple

V = V ./maximum(V);

bg = readpng("./img/test.png")
w = bg.width
h = bg.height

begin
	Drawing(w, h, "sim.png")
	origin()
	placeimage(bg, -w/2, -h/2)
	for i in 1:size(guesses,1)
		for j in 1:size(guesses,2)
			xinit = (i-1)*gsize
			yinit = (j-1)*gsize
			op = V[i,j] == 0.0 ? 0.0 : 0.8
			setopacity(op)
			sethue(V[i,j], 0.5, 1-V[i,j])
			rect(yinit-w/2, xinit-h/2, gsize, gsize, :fill)
		end
	end
	# NOTE the position is wrong
	setopacity(1.0)
	sethue("red")
	setline(4)
	rect(165*gsize-w/2, 80*gsize-h/2, 20*gsize, 20*gsize, :stroke)
	finish()
	preview()
end

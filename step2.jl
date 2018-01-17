# Step 2

D = zeros(Float64, size(guesses))
for i in eachindex(D)
    if guesses[i] == "F"
        D[i] = 0.0
    end
    if guesses[i] == "W"
        D[i] = 2.0
    end
    if guesses[i] == "N"
        D[i] = 10.0
    end
    if guesses[i] == "U"
        D[i] = 50.0
    end
    if guesses[i] == "R"
        D[i] = 50.0
    end
end

V = zeros(Int64, size(D))

x, y = 1, 1

xf, xt = x-1, x+1
yf, yt = y-1, y+1
xand = max(xf,1):min(xt,size(V,1))
yand = max(yf,1):min(yt,size(V,2))
tD = D[xand,yand].+0.000001

keep = sample(eachindex(tD), weights(vec(tD)))
# TODO convert index to tuple

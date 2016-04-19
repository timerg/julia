p = 10.0^-12
f = 10.0^-15
n = 10.0^-9
u = 10.0^-6
m = 10.0^-3

k = 10.0^3
x = 10.0^6
g = 10.0^9

# tech file parameter
toxp = 7.7e-9
toxn = 7.5e-9
toxe = 7.5E-09
Coxn = toxe/toxn
Coxp = toxe/toxp

# RC Analysis
function RC(c1, c2, f1, f2)
       c = (f2 * c2 - f1 * c1)/(f1 - f2)
       r = (1/f1-1/f2)/(c1-c2)/2/3.1415926
       w = 1/r/c
       return [c, r, w]
   end
function zdc(gm, gds)
    return (1 / (gds+gm))
end


# flicker Noise
function nf(norp::AbstractString, l, Id, f)
    if norp == "nch"
        KF = 1e-24
    elseif norp == "pch"
        KF = 3.5e-24
    else
         error("pch and nch only")
    end
    i2 = 2 * KF * Id / l^2 / f
end

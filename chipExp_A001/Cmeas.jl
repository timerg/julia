using Gadfly
using Cairo
using RDatasets
using CurveFit

function diff(xs, ys)
    l = length(xs)
    derv = DataArray{Float64, 1}(zeros(l))
    for i in collect(2 : (l-1))
        derv[i] = (ys[i + 1] - ys[i - 1])/(xs[i + 1] - xs[i - 1])
    end
    derv[1] = (ys[3] - ys[1])/(xs[3] - xs[1])
    derv[l] = (ys[l] - ys[l-2])/(xs[l] - xs[l-2])
    # derv[1] = NaN
    # derv[l] = NaN
    return derv
end

n = 1e-9
u = 1e-6
x = 1e6
k = 1e3
g = 1e9

dnw = readtable("./data/1212/nwb2-1.txt", separator='\t', header=true)

dnw[:gm] = diff(dnw[:Vg], dnw[:Id])
gm_Id = plot(dnw, x=:Id, y=:gm, Geom.line
            , Guide.yticks(ticks=[1e-7:1e-7:9e-7, 1e-6:1e-6:9e-6])
            , Guide.xticks(ticks=[-9:-1:-5, -6.15 ])
            # , Scale.y_log10
            , Scale.x_log10
            )

Id_Vg = plot(dnw, x=:Vg, y=:Id, Geom.line
            # , Scale.x_log10
            , Scale.y_log10
            , Guide.yticks(ticks=[-9:-1:-5, -6.67 ])
            , Guide.xticks(ticks=[0:1:3, 0.92 ])
            )


function HP(a::DataArray, x::Int64)
    l = length(a)
    i = 2
    out = copy(a)
    while i <= x
        out[i:l]  = out[i:l] - a[1:(l - i + 1)]
        i = i + 1
    end
    out = out[(2 + x):l] ./ x
    return out
end



dMeas_1k = readtable("./data/1212/1kHz.txt", separator='\t', header=true)
dMeas_10k = readtable("./data/1212/10kHz.txt", separator='\t', header=true)
dMeas_100k = readtable("./data/1212/100kHz.txt", separator='\t', header=true)
# dMeas_10k[:sine] = 0.022* sin((dMeas_10k[:second] - 0.0111) * 60 * 2 * pi) - 0.004


pMeas_1k = plot(dMeas_1k, x=:second, y=:Volt1, Geom.line)
# pMeas_10k = plot(layer(dMeas_10k, x=:second, y=:Volt1, Geom.line)
#                 ,layer(dMeas_10k, x=:second, y=:sine, Geom.line)
#                 )
pMeas_10k = plot(dMeas_10k, x=:second, y=dMeas_10k[:Volt1], Geom.line)
pMeas_100k = plot(dMeas_100k, x=:second, y=:Volt1, Geom.line)


d_1k = (dMeas_1k[1:333, 2] - dMeas_1k[334:666, 2]) ./ 2
d_10k = dMeas_10k[1:446, 2] - reverse(copy(dMeas_10k[447:892, 2]))

p_1k = plot(y=d_1k, Geom.line)
# d_100k




function Cval(gm::Float64, f::Float64, R::Float64, gain::Float64)
    c = ((gain / R)^2 - gm^2) / (1 - gain^2)
    return c
end




1+1


#

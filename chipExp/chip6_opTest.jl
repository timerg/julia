using Gadfly
using RDatasets
using Cairo

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

function init(a)
    l = length(a)
    a = a[2 : l]
    return(a :: Tuple)
end

function operate_row_(f :: Function, l, a0 :: DataArray, a1 :: DataArray, as :: Tuple)
    for i = 1 : l
        a0[i] = f(a0[i], a1[i])
    end
    if as == ()
        return a0
    else
        return operate_row_(f, l, a0, as[1], init(as))
    end
end

function operate_row(f :: Function, a1, a...)
    l = length(a1)
    a0 = @data(zeros(l))
    for i = 1 : l
        a0[i] = a1[i]
    end
    return operate_row_(f, l, a0, a[1], init(a))
end

function mean_onRow(d :: DataFrame, as :: Array = [])
    l = length(d)
    if as == []
        as = 1 : l
    end
    s = size(d, 1)
    mean = zeros(s)
    for i = as
        for j = 1 : s
            mean[j] = mean[j] + d[i][j]
        end
    end
    mean = mean / length(as)
    return mean
end

# input = readtable("./data/1001/sweep_inwd_meas_vimp&vopo_2.txt", header=true, separator='\t')

# input[:Vcross] = input[:Vimp_4_1_] + input[:Vnwd_2_1_]
#
# plot1 = plot(input, x = "Vimp_4_1_", y = "Vopo_3_1_", Geom.line, Geom.point)
# plot2 = plot(input, x = "Vcross", y = "Inwd_2_1_", Geom.line, Geom.point)

input = readtable("./data/1018/opTest.txt", header=true, separator='\t')
input[:Gain] = diff(input[:Vimp], input[:Vopo])
plot3 = Gadfly.plot(input, x="Vimp", y="Vopo", Geom.line, Geom.point
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )

plot4 = Gadfly.plot(input, x="Vopo", y="Gain", Geom.line, Geom.point
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )


draw(PNG("Fig/1018/1018_opTEst.png", 30cm, 16cm), plot3)


















#

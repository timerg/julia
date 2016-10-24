using Gadfly
using RDatasets
using Cairo
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

## nwd0


# input = readtable("./data/1005/1005_findR_upward.txt", header=true, separator='\t')
# input[:Vcross] = input[:Vimp] - input[:Vnwd]
# f01 = [0 0]
# frame = (:)
# f01 = linear_fit(Vector(input[:Vcross][frame]), Vector(input[:Inwd][frame]))
# f01[2] = 1/f01[2] # (Bias Pmos current, 1/R)
# title = "R = " * (string(round(f01[2])))
# input[:fitI] = f01[1] + input[:Vcross] / f01[2]
#
# plot_fit = plot(layer(input, x="Vcross", y="Inwd", Geom.line, Geom.point)
#            , layer(input, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
#            , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
#            , Guide.title(title)
#            , Scale.y_log10
#            , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
#            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#         )
#
# draw(PNG("Fig/1005/1005_fitCurve.png", 30cm, 16cm), plot_fit)

# data 1: This is proved to be wrong by data2: We shouldn't measure Vd, that value is not reliable

input = readtable("./data/1005/1005_mirror.txt", header=true, separator='\t')
# input[:Iimp] = (input[:Vnwd] - input[:Vimp]) ./ 92257
input[:Iimp] = (0.769 - input[:Vimp]) ./ 92257
input[:ratio] = input[:Im] ./ input[:Iimp]

plot1 = Gadfly.plot(input, x = "Im", y = "Iimp", Geom.line, Geom.point)
plot1 = Gadfly.plot(input, x = "Im", y = "ratio", Geom.line, Geom.point)



# data2: Better

input = readtable("./data/1005/1005_mirror2.txt", header=true, separator='\t')
input[:Iimp_buffer] = (input[:Vnwd] - input[:Vimp_buff]) ./ 92257
input[:Iimp_buffer_fixVds] = (0.78 - input[:Vimp_buff]) ./ 92257
input[:ratio_buffer] = input[:Im] ./ input[:Iimp_buffer]
input[:ratio_buffer_fixVds] = input[:Im] ./ input[:Iimp_buffer_fixVds]

plot_ImIb = Gadfly.plot(layer(input, x = "Im", y = "Iimp_buffer", Geom.line, Geom.point)
                      , layer(input, x = "Im", y = "Iimp_buffer_fixVds", Geom.line, Geom.point, Theme(default_color=colorant"green"))
                      , Guide.xticks(ticks = input[:Im])
                      , Guide.yticks(ticks = [1e-7, 1e-6, 2e-7])
                      , Guide.manual_color_key("Line", ["(Vnwd - Vimip)/R", "(0.78 - Vimip)/R"], ["deepskyblue", "green"])
                      , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                          , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                    )
draw(PNG("Fig/1005/1005_mirror_ImIb.png", 30cm, 16cm), plot_ImIb)

plot_ratio = Gadfly.plot(layer(input, x = "Im", y = "ratio_buffer", Geom.line, Geom.point)
                      , layer(input, x = "Im", y = "ratio_buffer_fixVds", Geom.line, Geom.point, Theme(default_color=colorant"green"))
                      , Guide.xticks(ticks = input[:Im])
                      , Guide.title("We shouldn't major vd, that value isn't reliable")
                      , Guide.manual_color_key("Line", ["(Vnwd - Vimip)/R", "(0.78 - Vimip)/R"], ["deepskyblue", "green"])
                      , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                          , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                    )
draw(PNG("Fig/1005/1005_mirror_ratio.png", 30cm, 16cm), plot_ratio)





















#
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



# 2-6


dnwg = readtable("./data/1004/nw2-6.txt", header=true, separator='\t')
dnwg[:Id_mean] = mean_onRow(dnwg, [2, 4, 6, 8])
dnwg[:transconductance] = 1 ./ diff(dnwg[:Vg_1_1_], dnwg[:Id_mean])

dnw = readtable("./data/1005/nw2-5_vdId.txt", header=true, separator='\t')
dnw[:rds_2_1_] = 1 ./ diff(dnw[:Vd_2_1_], dnw[:Id_2_1_])
dnw[:rds_2_2_] = 1 ./ diff(dnw[:Vd_2_2_], dnw[:Id_2_2_])

plot = Gadfly.plot(layer(dnw, x = "Id_2_1_", y = "rds_2_1_", Geom.line, Geom.point)
                 , layer(dnw, x = "Id_2_2_", y = "rds_2_2_", Geom.line, Geom.point)
                 , Scale.x_log10
                 , Scale.y_log10
                 , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                   , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )

draw(PNG("Fig/1005/rds_2-6.png", 30cm, 16cm), plot)


plot = Gadfly.plot(layer(dnw, x = "Id_2_1_", y = "rds_2_1_", Geom.line, Geom.point)
                 , layer(dnw, x = "Id_2_2_", y = "rds_2_2_", Geom.line, Geom.point)
                #  , layer(dnwg[dnwg[:transconductance] .!= Inf  &&  dnwg[:Id_mean] .> 0, :]
                 , layer(dnwg[6:21, :]
                        ,x = "Id_mean", y = "transconductance", Geom.line, Geom.point, Theme(default_color=colorant"green"))
                 , Scale.x_log10
                 , Scale.y_log10
                 , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                   , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )



















#
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
## 0913 and 0914

dnw = readtable("./data/0920/nw2-7.txt", separator='\t', header=true)
dnw[:Id_mean] = mean_onRow(dnw, [2, 4])
dnw[:Id_diff] = diff(dnw[:Vg_1_1_], dnw[:Id_mean])
dnw[:Id_min] = operate_row(min, dnw[:Id1], dnw[:Id2], dnw[:Id3], dnw[:Id4])
dnw[:Id_max] = operate_row(max, dnw[:Id1], dnw[:Id2], dnw[:Id3], dnw[:Id4])


# nwd0
    # measured: Vopo, Im_nonaccurate, Inwd
dgvt_nwd0_acc = readtable("./data/0920/gvt.txt", separator='\t', header=true)
dgvt_nwd0_acc[:Id_2_1_] = dgvt_nwd0_acc[:Id_2_1_] * (-1)
dgvt_nwd0_acc = dgvt_nwd0_acc[dgvt_nwd0_acc[:Id_2_1_] .> 0, :]
dgvt_nwd0_acc[:ratio] = dgvt_nwd0_acc[:Im_4_1_] ./ dgvt_nwd0_acc[:Id_2_1_]

pgvt_nwd0_acc = plot(layer(dgvt_nwd0_acc, x=:Vopo_3_1_, y=:Id_2_1_, Geom.point, Theme(default_color=colorant"green"))
            , layer(dnw, x=:Vg_1_1_, y=:Id_mean, ymin=:Id_min, ymax=:Id_max, Geom.line, Geom.errorbar)
            , Scale.y_log10
            , Guide.xlabel("Vg(V)")
            , Guide.ylabel("Id(A)")
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
draw(PNG("Fig/Chip5/GVT_nwd4_nacc.png", 18cm, 12cm), pgvt_nwd0_acc)
#
pmirror_nwd0 = plot(layer(dgvt_nwd0_acc, x=:Vopo_3_1_, y=:Im_4_1_, Geom.line)
            , layer(dgvt_nwd0_acc, x=:Vopo_3_1_, y=(dgvt_nwd0_acc[:Id_2_1_] * 4), Geom.line)
            , Scale.y_log10
            )

pratio_nwd0 = plot(layer(dgvt_nwd0_acc[dgvt_nwd0_acc[:ratio] .< 100, :], x=:Id_2_1_, y=:ratio, Geom.line, Geom.point)
            , Guide.yticks(ticks=[1:5, 5:5:10])
            # , Guide.xticks(ticks=[1e-6:1e-6:1e-5])
            # , Scale.x_log10
            )



# draw(PNG("Fig/gvt_nwd4_nacc_mirrorError.png", 18cm, 12cm), pmirror_error)
#
# p_time_I = plot(layer(dgvt_nwd4_nacc, y=:Id_2_1_, Geom.line)
#             , layer(dgvt_nwd4_nacc, y=:Im_4_1_, Geom.line)
#             )
#
# p_time_V = plot(layer(dgvt_nwd4_nacc, y=:Vopo_3_1_, Geom.line)
#             )

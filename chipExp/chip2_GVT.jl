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
    s = size(dnw, 1)
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

dnw = readtable("./data/0914/nw2-8.txt", separator='\t', header=true)
dnw[:Id_mean] = mean_onRow(dnw, [2, 4])
dnw[:Id_diff] = diff(dnw[:Vg_1_1_], dnw[:Id_mean])
dnw[:Id_min] = operate_row(min, dnw[:Id_2_1_], dnw[:Id_2_2_])
dnw[:Id_max] = operate_row(max, dnw[:Id_2_1_], dnw[:Id_2_2_])


# nwd4
    # measured: Vopo, Im_nonaccurate, Inwd
dgvt_nwd4_nacc = readtable("./data/0914/gvt_nw2-8_nwd4.txt", separator='\t', header=true)
dgvt_nwd4_nacc[:Id_2_1_] = abs(dgvt_nwd4_nacc[:Id_2_1_])
dgvt_nwd4_nacc[:Im_4_1_] = abs(dgvt_nwd4_nacc[:Im_4_1_])

pnw = plot(layer(dnw[dnw[:Id_diff] .> 0, :], x=:Vg_1_1_, y=:Id_diff, Geom.line, Theme(default_color=colorant"green"))
        , layer(dnw[dnw[:Id_diff] .> 0, :], x=:Vg_1_1_, y=:Id_mean, Geom.line)
        , Scale.y_log10
        )

pgvt_nwd4_nacc = plot(layer(dgvt_nwd4_nacc, x=:Vopo_3_1_, y=:Id_2_1_, Geom.line, Theme(default_color=colorant"green"))
            , layer(dnw, x=:Vg_1_1_, y=:Id_mean, ymin=:Id_min, ymax=:Id_max, Geom.line, Geom.errorbar)
            , Scale.y_log10
            , Guide.xlabel("Vg(V)")
            , Guide.ylabel("Id(A)")
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
draw(PNG("Fig/GVT_nwd4_nacc.png", 18cm, 12cm), pgvt_nwd4_nacc)

pmirror_nwd4 = plot(layer(dgvt_nwd4_nacc, x=:Vopo_3_1_, y=:Im_4_1_, Geom.line)
            , layer(dgvt_nwd4_nacc, x=:Vopo_3_1_, y=(dgvt_nwd4_nacc[:Id_2_1_] * 4), Geom.line)
            , Scale.y_log10
            )
pmirror_error = plot(dgvt_nwd4_nacc, x=:Vopo_3_1_, y=(dgvt_nwd4_nacc[:Im_4_1_] - dgvt_nwd4_nacc[:Id_2_1_] * 4), Geom.line
            , Scale.y_continuous(minvalue=1e-7, maxvalue=9e-7)
            , Guide.yticks(ticks=[1e-7, 7e-7, 1e-6:1e-6:4e-6])
            , Guide.xlabel("Vg(V)")
            , Guide.ylabel("Im - Id * 4")
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
draw(PNG("Fig/gvt_nwd4_nacc_mirrorError.png", 18cm, 12cm), pmirror_error)

p_time_I = plot(layer(dgvt_nwd4_nacc, y=:Id_2_1_, Geom.line)
            , layer(dgvt_nwd4_nacc, y=:Im_4_1_, Geom.line)
            )

p_time_V = plot(layer(dgvt_nwd4_nacc, y=:Vopo_3_1_, Geom.line)
            )

# nwd1
    # measured: Im_accurate, Inwd, Vopo
    # unmeasured: Vimp
dgvt_nwd1_acc = readtable("./data/0914/gvt_nw2-8_nwd1_Im.txt", separator='\t', header=true)
dgvt_nwd1_acc[:Id_2_1_] = abs(dgvt_nwd1_acc[:Id_2_1_])
dgvt_nwd1_acc[:Im_4_1_] = abs(dgvt_nwd1_acc[:Im_4_1_])

pgvt_nwd1_acc = plot(layer(dgvt_nwd1_acc, x=:Vopo_3_1_, y=:Id_2_1_, Geom.line, Theme(default_color=colorant"green"))
            , layer(dgvt_nwd4_nacc, x=:Vopo_3_1_, y=:Id_2_1_, Geom.line, Theme(default_color=colorant"olive"))
            , layer(dnw, x=:Vg_1_1_, y=:Id_mean, ymin=:Id_min, ymax=:Id_max, Geom.line, Geom.errorbar, order=1)
            , Scale.y_log10
            , Guide.xlabel("Vg(V)")
            , Guide.ylabel("Id(A)")
            , Guide.manual_color_key("Line", ["NwSweep", "nwd1_accurateMirror", "gvt:nwd4_non-accurateMirror"], ["deepskyblue", "green", "olive"])
            , Theme(background_color=colorant"white", key_title_font_size=12pt, key_label_font_size=12pt
                , major_label_font_size=12pt, minor_label_font_size=12pt, line_width=1pt)
            )
draw(PNG("Fig/GVT_nwd1_acc.png", 24cm, 12cm), pgvt_nwd1_acc)

pmirror_nwd1_acc = plot(layer(dgvt_nwd1_acc, x=:Vopo_3_1_, y=:Im_4_1_, Geom.line)
            , layer(dgvt_nwd1_acc, x=:Vopo_3_1_, y=(dgvt_nwd4_nacc[:Id_2_1_] * 4), Geom.line)
            , Scale.y_log10
            )

    # To find whether there are leakage current to Vimp
    # measured: Vimp, Im_accurate, Inwd
    # unmeasured: Vopo
dgvt_ImVimp = readtable("./data/0914/gvt_nw2-8_nwd1_Im_Vimp.txt", separator='\t', header=true)
dgvt_ImVimp[:Id_2_1_] = (dgvt_ImVimp[:Id_2_1_]) * (-1)
dgvt_ImVimp[:Im_4_1_] = (dgvt_ImVimp[:Im_4_1_]) * (-1)
pgvt_ImVimp_mirror = plot(dgvt_ImVimp, x=:Im_4_1_, y=dgvt_ImVimp[:Id_2_1_ ]* 4, Geom.line)

pgvt_ImVimp_error = plot(y=dgvt_ImVimp[:Im_4_1_][1:230] - 4 * dgvt_ImVimp[:Id_2_1_][1:230], Geom.line
                    , Guide.yticks(ticks=[-3e-6:1e-6:-1e-6, -5.4e-7])
                    , Guide.xlabel("points")
                    , Guide.ylabel("Im - Id * 4")
                    , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                        , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                    )
draw(PNG("Fig/gvt_nwd1_acc_mirrorError.png", 18cm, 12cm), pgvt_ImVimp_error)

dgvt_ImVimp[:Iimp] = (0.82 - dgvt_ImVimp[:Vimp_3_1_]) ./ 70000
dgvt_ImVimp[:ratio] = dgvt_ImVimp[:Im_4_1_] ./ (dgvt_ImVimp[:Iimp] + dgvt_ImVimp[:Id_2_1_])

pgvt_ImVimp_ratio = plot(dgvt_ImVimp[ (dgvt_ImVimp[:ratio] .< 10) & (dgvt_ImVimp[:ratio] .> -10), :], x="Im_4_1_", y="ratio", Geom.line
                    , Scale.x_continuous(format=:scientific)
                    , Guide.xlabel("Im(A)")
                    , Guide.ylabel("Im/(Id + Vimp/R(70k))")
                    , Guide.yticks(ticks=[0:2:10])
                    , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                        , major_label_font_size=12pt, minor_label_font_size=12pt, line_width=3pt)
                    )
draw(PNG("Fig/gvt_nwd1_acc_mirrorRaio.png", 18cm, 12cm), pgvt_ImVimp_ratio)


pgvt_ImVimp_time = plot(layer(dgvt_ImVimp, y=:Id_2_1_, Geom.line)
                        , layer(dgvt_ImVimp, y=:Id_2_1_, Geom.line)
                    )
pgvt_ImVimp_ImVimp = plot(dgvt_ImVimp, x=:Im_4_1_, y=:Vimp_3_1_, Geom.line)


















a = 1


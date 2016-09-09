using Gadfly
using Cairo
using RDatasets
using CurveFit


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

## 0906

dnw = readtable("./data/0906/nw_vbg_2-8.txt", separator='\t', header=true)
dm50k = readtable("./data/0906/Meas_ohmv50k.txt", separator='\t', header=true)
dm2x = readtable("./data/0906/Meas_ohmv2Meg.txt", separator='\t', header=true)

dnw[:Id_min] = operate_row(min, dnw[:Id_2_1_], dnw[:Id_2_2_], dnw[:Id_2_3_], dnw[:Id_2_4_])
dnw[:Id_max] = operate_row(max, dnw[:Id_2_1_], dnw[:Id_2_2_], dnw[:Id_2_3_], dnw[:Id_2_4_])
dnw[:Id_mean] = mean_onRow(dnw, [2, 4, 6, 8])

pgvt = plot(layer(dnw, x="Vg_1_1_", y="Id_mean", ymin="Id_min", ymax="Id_max"
                , Geom.line, Geom.point, Theme(default_color=colorant"green", line_width=1pt)
                , Geom.errorbar
                ),
             layer(dm50k, x="Vopo_3_1_", y=abs(dm50k[:Id_2_1_])
                , Geom.point, Theme(default_color=colorant"deepskyblue", line_width=3pt)),
             layer(dm2x, x="Vopo_3_1_", y=abs(dm2x[:Id_2_1_])
                , Geom.point, Theme(default_color=colorant"darkred", line_width=3pt)),
             Scale.y_log10,
             Guide.manual_color_key("Line and Points", ["MeasData", "Id: 2Meg", "Id: 50k"], ["green", "deepskyblue", "darkred"]),
             Guide.ylabel("Id(A)"), Guide.xlabel("Vg(V)"),
             Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt
                 )
    )

draw(PNG("GVT_0906.png", 30cm, 20cm), pgvt)

## 0907

dnw = readtable("./data/0907/nw_vbg_2-8.txt", separator='\t', header=true)
dm_6min = readtable("./data/0907/gvt_2meg_6min-7min.txt", separator='\t', header=true)
dm_11min = readtable("./data/0907/gvt_2meg_11min-13min.txt", separator='\t', header=true)

# dnw[:Id_min_0to8] = operate_row(min, dnw[:Id_0min], dnw[:Id_8min], dnw[:Id_16min])
# dnw[:Id_max_0to8] = operate_row(max, dnw[:Id_0min], dnw[:Id_8min], dnw[:Id_16min])
# dnw[:Id_mean_0to8] = mean_onRow(dnw, [2, 3, 4])
# dnw[:Id_min_8to16] = operate_row(min, dnw[:Id_0min], dnw[:Id_8min], dnw[:Id_16min])
# dnw[:Id_max_8to16] = operate_row(max, dnw[:Id_0min], dnw[:Id_8min], dnw[:Id_16min])
# dnw[:Id_mean_8to16] = mean_onRow(dnw, [2, 3, 4])
leng = length(dnw[1])
dnw[:Id_min] = operate_row(min, dnw[:Id_0min], dnw[:Id_8min], dnw[:Id_16min], dnw[:Id_24min])
dnw[:Id_max] = operate_row(max, dnw[:Id_0min], dnw[:Id_8min], dnw[:Id_16min], dnw[:Id_24min])
dnw[:Id_mean] = mean_onRow(dnw, [2, 3, 4, 5])
dnw[:name_0min] = ""
dnw[:name_0min][leng] = "0min"
dnw[:name_8min] = ""
dnw[:name_8min][leng] = "8min"
dnw[:name_16min] = ""
dnw[:name_16min][leng] = "16min"
dnw[:name_24min] = ""
dnw[:name_24min][leng] = "24min"

pnw = plot(layer(dnw, x="Vg", y="Id_mean", ymin="Id_min", ymax="Id_max"
                , Geom.line, Theme(default_color=colorant"green", line_width=1pt)
                , Geom.errorbar
            )
            , layer(dnw, x="Vg", y="Id_0min", label="name_0min", Geom.label, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=0.5pt))
            , layer(dnw, x="Vg", y="Id_8min", label="name_8min", Geom.label, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=0.5pt))
            , layer(dnw, x="Vg", y="Id_16min", label="name_16min", Geom.label, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=0.5pt))
            , layer(dnw, x="Vg", y="Id_24min", label="name_24min", Geom.label, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=0.5pt))
            , Guide.manual_color_key("Line", ["Mean and Errorbar", "0, 8, 16, 24mins"], ["green", "deepskyblue"])
            , Guide.title("Nanowire Id-Vg Sweep with time interval=8mins")
            , Guide.ylabel("Id(A)"), Guide.xlabel("Vg(V)")
            , Theme(background_color=colorant"white", key_title_font_size=12pt, key_label_font_size=12pt
                , major_label_font_size=12pt, minor_label_font_size=12pt
            )
    )

pgvt_0907_6min = plot(layer(dnw, x="Vg", y="Id_mean", ymin="Id_min", ymax="Id_max"
                , Geom.line, Geom.point, Theme(default_color=colorant"green", line_width=1pt)
                , Geom.errorbar
                ),
             layer(dm_6min, x="Vopo_3_1_", y=abs(dm_6min[:Id_2_1_])
                , Geom.point, Theme(default_color=colorant"deepskyblue", line_width=3pt)),
             Scale.y_log10,
             Guide.manual_color_key("Line and Points", ["NwSweep\nVariance within 45mins", "Idmeas"], ["green", "deepskyblue"]),
             Guide.ylabel("Id(A)"), Guide.xlabel("Vg(V)"),
             Theme(background_color=colorant"white", key_title_font_size=16pt, key_label_font_size=16pt
                 , major_label_font_size=16pt, minor_label_font_size=16pt
             )
    )


pgvt_0907_11min = plot(layer(dnw, x="Vg", y="Id_mean", ymin="Id_min", ymax="Id_max"
                , Geom.line, Geom.point, Theme(default_color=colorant"green", line_width=1pt)
                , Geom.errorbar
                ),
             layer(dm_11min, x="Vopo_3_1_", y=abs(dm_11min[:Id_2_1_])
                , Geom.point, Theme(default_color=colorant"deepskyblue", line_width=3pt)),
             Scale.y_log10,
             Guide.manual_color_key("Line and Points", ["NwSweep\nvariance within 45mins", "Idmeas"], ["green", "deepskyblue"]),
             Guide.ylabel("Id(A)"), Guide.xlabel("Vg(V)"),
             Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt
                 )
    )

draw(PNG("nw2-8_0907.png", 18cm, 12cm), pnw)
draw(PNG("GVT_0907_6min.png", 30cm, 20cm), pgvt_0907_6min)
draw(PNG("GVT_0907_11min.png", 30cm, 20cm), pgvt_0907_11min)

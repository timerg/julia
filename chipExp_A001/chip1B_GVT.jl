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

dnw = readtable("./data/1130/nw1-7.txt", separator='\t', header=true)
dnw[:gm] = diff(dnw[:Vg_1_1_], dnw[:Id_2_1_])

plot_Idgm = plot(dnw, x=:Id_2_1_, y=:gm, Geom.line
                , Scale.y_log10
                , Scale.x_log10
                , Guide.xlabel("ID(A)")
                , Guide.ylabel("gm")
                , Guide.xticks(ticks=collect(-11:-4))
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )
draw(PNG("Fig/NW/nw1-7_Idgm.png", 24cm, 15cm), plot_Idgm)

# 我們的掃法為將vm由大調到小

# 1B
dgvt_nwd0_A = readtable("./data/1130/GVT_1B_ch0.txt", separator='\t', header=true)
dgvt_nwd0_B = readtable("./data/1130/GVT_1B_ch0_Im=2u.txt", separator='\t', header=true)
dgvt_nwd0_C = readtable("./data/1130/GVT_1B_ch0_rm=42k.txt", separator='\t', header=true)
dgvt_nwd0_A[:Id_2_1_] = dgvt_nwd0_A[:Id_2_1_] * (-1)
dgvt_nwd0_B[:Id_2_1_] = dgvt_nwd0_B[:Id_2_1_] * (-1)
dgvt_nwd0_C[:Id_2_1_] = dgvt_nwd0_C[:Id_2_1_] * (-1)
dgvt_nwd0_A[:Im_1_1_] = dgvt_nwd0_A[:Im_1_1_] * (-1)
dgvt_nwd0_B[:Im_1_1_] = dgvt_nwd0_B[:Im_1_1_] * (-1)
dgvt_nwd0_C[:Im_1_1_] = dgvt_nwd0_C[:Im_1_1_] * (-1)
pgvt_nwd0 = plot(
              layer(dgvt_nwd0_A, x=:Vopo_3_1_, y=:Id_2_1_, Geom.line, Theme(default_color=colorant"green"))
            , layer(dgvt_nwd0_B, x=:Vopo_3_1_, y=:Id_2_1_, Geom.line, Theme(default_color=colorant"maroon"))
            , layer(dgvt_nwd0_C, x=:Vopo_3_1_, y=:Id_2_1_, Geom.line, Theme(default_color=colorant"darkkhaki"))
            , layer(dnw[6:19, :], x=:Vg_1_1_, y=:Id_2_1_, Geom.line)
            , Scale.y_log10
            , Guide.xlabel("Vg(V)")
            , Guide.ylabel("Id(A)")
            , Guide.title("nw1-7, chip1B, Might cause by electrolysis?")
            , Guide.manual_color_key("Line", ["cn=0.82", "cn=0.939", "cn=896"], ["green", "maroon", "darkkhaki"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
draw(PNG("Fig/Chip1/GVT_IdVg.png", 24cm, 20cm), pgvt_nwd0)

pId_Im = plot(
              layer(dgvt_nwd0_A, x=:Im_1_1_, y=:Id_2_1_, Geom.line, Geom.point, Theme(default_color=colorant"green"))
            , layer(dgvt_nwd0_B, x=:Im_1_1_, y=:Id_2_1_, Geom.line, Geom.point, Theme(default_color=colorant"maroon"))
            , layer(dgvt_nwd0_C, x=:Im_1_1_, y=:Id_2_1_, Geom.line, Geom.point, Theme(default_color=colorant"darkkhaki"))
            , Scale.y_log10
            , Scale.x_log10
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )

pId_Vopi = plot(
              layer(dgvt_nwd0_A[15:51, :], x=:Id_2_1_, y=:Vopi_4_1_, Geom.line, Geom.point, Theme(default_color=colorant"green"))
            , layer(dgvt_nwd0_B[28:51, :], x=:Id_2_1_, y=:Vopi_4_1_, Geom.line, Geom.point, Theme(default_color=colorant"maroon"))
            , layer(dgvt_nwd0_C[22:51, :], x=:Id_2_1_, y=:Vopi_4_1_, Geom.line, Geom.point, Theme(default_color=colorant"darkkhaki"))
            , Guide.yticks(ticks=[0.4:0.2:1, 0.7:0.02:0.88])
            , Guide.xlabel("ID(A)")
            , Guide.ylabel("Vopi(V)")
            , Guide.title("nw1-7, chip1B")
            , Scale.x_log10
            , Guide.manual_color_key("Line", ["cn=0.82", "cn=0.939", "cn=0.896"], ["green", "maroon", "darkkhaki"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )

draw(PNG("Fig/Chip1/GVT_VopiId.png", 24cm, 20cm), pId_Vopi)



# 1205
# NwB 3-12

dnw = readtable("./data/1205/nwB3-11.txt", separator='\t', header=true)
dnw[:gm] = diff(dnw[:Vg_1_1_], dnw[:Id_2_1_])
pgm_Id = plot(dnw[3:21, :], x=:Id_2_1_, y=:gm, Geom.line, Theme(default_color=colorant"green", line_width=3pt)
            , Scale.x_log10
            , Scale.y_log10
            , Guide.ylabel("gm")
            , Guide.xlabel("Id(A)")
            , Guide.xticks(ticks = [-4:-1:-8, -5.8])
            , Guide.title("NW, not GVT")
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
dgvt_nwd0_A = readtable("./data/1205/GVT_1B_nwd0.txt", separator='\t', header=true)
dgvt_nwd0_B = readtable("./data/1205/GVT_1B_nwd0_2.txt", separator='\t', header=true)
dgvt_nwd0_A[:Id_2_1_] = dgvt_nwd0_A[:Id_2_1_] * (-1)
dgvt_nwd0_B[:Id_2_1_] = dgvt_nwd0_B[:Id_2_1_] * (-1)
dgvt_nwd0_A[:Im_1_1_] = dgvt_nwd0_A[:Im_1_1_] * (-1)
dgvt_nwd0_B[:Im_1_1_] = dgvt_nwd0_B[:Im_1_1_] * (-1)

pgvt_nwd0 = plot(
              layer(dgvt_nwd0_A, x=:Vopo_3_1_, y=:Id_2_1_, Geom.line, Geom.point, Theme(default_color=colorant"green", line_width=3pt))
            # , layer(dgvt_nwd0_B, x=:Vopo_3_1_, y=:Id_2_1_, Geom.line, Theme(default_color=colorant"maroon"))
            , layer(dnw[6:19, :], x=:Vg_1_1_, y=:Id_2_1_, Geom.line, Geom.point, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , Scale.y_log10
            , Guide.xlabel("Vg(V)")
            , Guide.ylabel("Id(A)")
            , Guide.yticks(ticks = [-5:-1:-7, -5.8])
            , Guide.title("NWB 3-12, ")
            , Guide.manual_color_key("Line", ["GVT_1", "NW"], ["green", "deepskyblue"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )

draw(PNG("Fig/NW/Idgm_NWB3-12.png", 30cm, 16cm), pgm_Id)
draw(PNG("Fig/gvt/1B_NWB3-12_GVT.png", 30cm, 16cm), pgvt_nwd0)

pId_Vopi = plot(
              layer(dgvt_nwd0_A, x=:Id_2_1_, y=:Vopi_4_1_, Geom.line, Theme(default_color=colorant"green"))
            # , layer(dgvt_nwd0_B, x=:Id_2_1_, y=:Vopi_4_1_, Geom.line, Theme(default_color=colorant"maroon"))
            , Guide.xticks(ticks=[-6.7:0.2:-4.7])
            , Guide.xlabel("ID(A)")
            , Guide.ylabel("Vopi(V)")
            # , Guide.title("nwB3-12, chip1B")
            , Scale.x_log10
            , Guide.manual_color_key("Line", ["GVT_1", "GVT_2"], ["green", "maroon"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
draw(PNG("Fig/gvt/1B_NWB3-12_IdVopi.png", 30cm, 16cm), pId_Vopi)

pId_Im = plot(
              layer(dgvt_nwd0_A[dgvt_nwd0_A[:Id_2_1_] .> 2e-7, :], x=:Im_1_1_, y=:Id_2_1_, Geom.line, Geom.point, Theme(default_color=colorant"green"))
            , layer(dgvt_nwd0_B[dgvt_nwd0_B[:Id_2_1_] .> 2e-7, :], x=:Im_1_1_, y=:Id_2_1_, Geom.line, Geom.point, Theme(default_color=colorant"maroon"))
            , Scale.y_log10
            , Scale.x_log10
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
dgvt_nwd0_A[:ratio] = dgvt_nwd0_A[:Id_2_1_] ./ dgvt_nwd0_A[:Im_1_1_]
dgvt_nwd0_B[:ratio] = dgvt_nwd0_B[:Id_2_1_] ./ dgvt_nwd0_B[:Im_1_1_]

pratio_Im = plot(
              layer(dgvt_nwd0_A[dgvt_nwd0_A[:Id_2_1_] .> 2e-7, :], x=:Im_1_1_, y=:ratio, Geom.line, Geom.point, Theme(default_color=colorant"green"))
            # , layer(dgvt_nwd0_B[dgvt_nwd0_B[:Id_2_1_] .> 2e-7, :], x=:Im_1_1_, y=:ratio, Geom.line, Geom.point, Theme(default_color=colorant"maroon"))
            # , Scale.y_log10
            , Guide.yticks(ticks=[10, 50, 100])
            , Scale.x_log10

            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )

2 + 2
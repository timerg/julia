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



## 1222 ph4 & 7

dgvt_nwd0_1 = readtable("./data/0101/gvt.txt", separator='\t', header=true)
dgvt_nwd0_1[:Inwd_4_1_] = dgvt_nwd0_1[:Inwd_4_1_] * (-1)
dgvt_nwd0_1[:gm] = diff(dgvt_nwd0_1[:Vopo_3_1_], dgvt_nwd0_1[:Inwd_4_1_])

dgvt_nwd0_1_Ib = readtable("./data/0101/gvt_Ibcal.txt", separator='\t', header=true)
dgvt_nwd0_1_Ib[:Ib_1_1_] = dgvt_nwd0_1_Ib[:Ib_1_1_] * (-1)
dgvt_nwd0_1_Ib[:Ibias_cal] = (dgvt_nwd0_1_Ib[:Vnwd_3_1_] - dgvt_nwd0_1_Ib[:Vopi_2_1_]) ./ 108.432e3

dgvt_nwd0_1[:Ibias_cal] = dgvt_nwd0_1_Ib[:Ibias_cal]
dgvt_nwd0_1[:gm_cal] = diff(dgvt_nwd0_1[:Vopo_3_1_], dgvt_nwd0_1[:Ibias_cal])
dgvt_nwd0_1[:gm_error] = abs((dgvt_nwd0_1[:gm] - dgvt_nwd0_1[:gm_cal]) ./ dgvt_nwd0_1[:gm])

pgmId_measdata_1 = plot(layer(dgvt_nwd0_1[(dgvt_nwd0_1[:gm] .> 0)&(dgvt_nwd0_1[:gm] .< 1e-5), :], x=:Ibias_cal, y=:gm, Geom.line, Geom.point, Theme(line_width=1pt, default_color=colorant"deepskyblue"))
                    , layer(dgvt_nwd0_1[(dgvt_nwd0_1[:gm_cal] .> 0)&(dgvt_nwd0_1[:gm_cal] .< 1e-5), :], x=:Ibias_cal, y=:gm_cal, Geom.line, Geom.point, Theme(line_width=1pt, default_color=colorant"green"))
                    , Scale.y_log10
                    # , Scale.x_log10
                    , Guide.xlabel("Ibias(A)")
                    , Guide.ylabel("gm")
                    # , Guide.yticks(ticks = [-4:-1:-8; -6.52])
                    # , Guide.yticks(ticks = [-4:-1:-8; -5.7])
                    , Guide.title("nw2-12, chip1B, DC Sweep mode of gm comparison, gm is limited of 300n")
                    , Guide.manual_color_key("", ["Calculated from Ibias", "Calculated from ID"], ["green", "deepskyblue"])
                    # , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    #     , major_label_font_size=18pt, minor_label_font_size=18pt)
                    )


# draw(PNG("Fig/pHTest/nw2-12_ph4and7_Idgm.png", 24cm, 15cm), plot_Idgm_ph4and7)
#
dnw = readtable("./data/0101/nw2-3.txt", separator='\t', header=true)
dnw[:Is_3_1_] = dnw[:Is_3_1_] * (-1)
dgvt_manu_10x = readtable("./data/0101/gvt_manual Chip1B_10x.txt", separator='\t', header=true)
dgvt_manu_1x = readtable("./data/0101/gvt_manual Chip1B_1x.txt", separator='\t', header=true)
dgvt_manu = vcat(dgvt_manu_10x, dgvt_manu_1x)
dgvt_manu[:gm] = diff(dgvt_manu[:Vopo_3_1_], dgvt_manu[:Inwd_4_1_])
dgvt_manu[:gm_cal] = diff(dgvt_manu[:Vopo_3_1_], dgvt_manu[:Ibias_cal])
dgvt_manu[:I_diff] = dgvt_manu[:Inwd_4_1_] - dgvt_manu[:Ibias_cal]
dgvt_manu[:gm_error] = abs(dgvt_manu[:gm_cal] - dgvt_manu[:gm]) ./ dgvt_manu[:gm]

dnw_manu = readtable("./data/0103/nw2-3.txt", separator='\t', header=true)
dnw_manu[:Is_3_1_] = dnw_manu[:Is_3_1_] * (-1)
dnw_manu[:gm] = diff(dnw_manu[:Vg_1_1_], dnw_manu[:Is_3_1_])

dgvt_manu[:Ileak] = (dgvt_manu[:Vopi_2_1_] - 0.802) ./ 100000

pnw_gmId_manu = plot(dnw_manu[8:21, :], x=:Is_3_1_, y=:gm, Geom.line
                        , Scale.y_log10
                        , Scale.x_log10
                        )

pgvt_IdVg_manu = plot(
              layer(dgvt_manu[1:50, :], x=:Vopo_3_1_, y=:Inwd_4_1_, Geom.line, Theme(default_color=colorant"#72A2C0", line_width=3pt))
            , layer(dgvt_manu[1:50, :], x=:Vopo_3_1_, y=:Ibias_cal, Geom.line, Theme(default_color=colorant"#00743F", line_width=3pt))
            # , layer(dnw_manu[8:21, :], x=:Vg_1_1_, y=:Is_3_1_, Geom.line, Theme(default_color=colorant"darkkhaki"))
            , layer(dnw[8:21, :], x=:Vg_1_1_, y=:Is_3_1_, Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
            , Scale.y_log10
            , Guide.xlabel("Vg(V)")
            , Guide.ylabel("I(A)")
            , Guide.title("0101/dgvt_manu_10x and 1x")
            , Guide.xticks(ticks = [1:1:3])
            , Guide.manual_color_key("Line", ["Vopo_ID", "Vopo_Ibias", "NwSweep"], ["#72A2C0", "#00743F", "maroon"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt)
            )
# x = plot(x = dgvt_manu[:Vopo_3_1_],y = (dgvt_manu[:Inwd_4_1_] - dgvt_manu[:Ibias_cal]), Geom.line, Geom.point)
# draw(PNG("Fig/Chip1/GVT_0103Manual.png", 24cm, 15cm), pgvt_IdVg_manu)
pgvt_Ileak = plot(dgvt_manu[7:50, :], x=:Vopo_3_1_, y=:Ileak, Geom.line)

#
pgvt_gmId_manu = plot(
              layer(dgvt_manu, y=:gm, x=:Inwd_4_1_, Geom.point, Theme(default_color=colorant"deepskyblue"))
            , layer(dgvt_manu, y=:gm_cal, x=:Ibias_cal, Geom.line, Geom.point, Theme(default_color=colorant"green"))
            , layer(dnw_manu[8:21, :], y=:gm, x=:Is_3_1_, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , Scale.y_log10
            , Scale.x_log10
            , Guide.xlabel("I(A)")
            , Guide.ylabel("gm")
            , Guide.title("nw2-4, chip1B")
            , Guide.manual_color_key("Line", ["Vopo_ID", "Vopo_Ibias"], ["deepskyblue", "green"])
            # , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            #     , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
            )



dgvt_manu_10x_2 = readtable("./data/0101/gvt_manual Chip1B_10x_2.txt", separator='\t', header=true)
dgvt_manu_10x_2[:gm] = diff(dgvt_manu_10x_2[:Vopo_3_1_], dgvt_manu_10x_2[:Inwd_4_1_])
dgvt_manu_10x_2[:gm_cal] = diff(dgvt_manu_10x_2[:Vopo_3_1_], dgvt_manu_10x_2[:Ibias_cal])
dnw_manu_10x_2 = readtable("./data/0103/nw2-3_2.txt", separator='\t', header=true)
dnw_manu_10x_2[:Is_3_1_] = dnw_manu_10x_2[:Is_3_1_] * (-1)
dnw_manu_10x_2[:gm] = diff(dnw_manu_10x_2[:Vg_1_1_], dnw_manu_10x_2[:Is_3_1_])

pnw_gmId_manu_2 = plot(dnw_manu_10x_2[10:14, :], x=:Is_3_1_, y=:gm, Geom.line
                        , Scale.y_log10
                        , Scale.x_log10
                        )

pgvt_IdVg_manu_2 = plot(
              layer(dgvt_manu_10x_2, x=:Vopo_3_1_, y=:Inwd_4_1_, Geom.line, Theme(default_color=colorant"green"))
            , layer(dgvt_manu_10x_2, x=:Vopo_3_1_, y=:Ibias_cal, Geom.line, Theme(default_color=colorant"maroon"))
            # , layer(dnw[10:14, :], x=:Vg_1_1_, y=:Is_3_1_, Geom.line)
            , Scale.y_log10
            , Guide.xlabel("Vg(V)")
            , Guide.ylabel("I(A)")
#             , Guide.title("nw2-12, chip1B")
            , Guide.manual_color_key("Line", ["Vopo_ID", "Vopo_Ibias", "NW"], ["green", "maroon", "deepskyblue"])
#             , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
pgvt_IdVg_manu_2_Idiff = plot(x = dgvt_manu_10x_2[:Vopo_3_1_], y = (dgvt_manu_10x_2[:Ibias_cal] - dgvt_manu_10x_2[:Inwd_4_1_]), Geom.line)
# pgmId_measdata_4 = plot(layer(dgvt_nwd0_ph4[2:20, :], x=:Ibias, y=:gm, Geom.point, Geom.line, Theme(line_width=1pt, default_color=colorant"deepskyblue"))
#                     , layer(dgvt_nwd0_ph4[2:20, :], x=:Ibias, y=:gm_meas, Geom.point, Geom.line, Theme(line_width=1pt, default_color=colorant"green"))
#                     , Scale.y_log10
#                     , Scale.x_log10
#                     , Guide.xlabel("ID(A)")
#                     , Guide.ylabel("gm")
#                     , Guide.title("nw2-12, chip1B, pH=4, DC Sweep mode of pHTest")
#                     , Guide.manual_color_key("", ["Calculated from Ibias", "Calculated from ID"], ["green", "deepskyblue"])
#                     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                         , major_label_font_size=18pt, minor_label_font_size=18pt)
#                     )
# pgmId_diff_4 = plot(layer(dgvt_nwd0_ph4[2:20, :], x=:gm, y=:gm_error, Geom.point, Geom.line, Theme(line_width=1pt, default_color=colorant"deepskyblue"))
#                     # , Scale.y_log10
#                     , Scale.x_log10
#                     , Guide.xlabel("gm")
#                     , Guide.ylabel("gm_diff")
#                     , Guide.title("nw2-12, chip1B, pH=4, DC Sweep mode: gm comparison")
#                     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                         , major_label_font_size=18pt, minor_label_font_size=18pt)
#                     )
#
# draw(PNG("Fig/gvt/gvt_IdVg_NWB2-12_ph4_gm>1u.png", 24cm, 15cm), pIdVg_measdata_4)
# draw(PNG("Fig/gvt/gvt_Idgm_NWB2-12_ph4_gm>1u.png", 24cm, 15cm), pgmId_measdata_4)
# draw(PNG("Fig/gvt/gvt_gmcompare_NWB2-12_ph4_gm>1u.png", 24cm, 15cm), pgmId_diff_4)
#
# ## ph4 compare with ph7
#
# pIdgm_4and7 = plot( layer(dnw_ph4[2:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(default_color=colorant"green", line_width=2pt))
#                 , layer(dnw_ph7[2:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(line_width=2pt))
#                 , Scale.y_log10
#                 , Scale.x_log10
#                 , Guide.xlabel("ID(A)")
#                 , Guide.ylabel("gm")
#                 # , Guide.title("nw2-12, chip1B, DC Sweep mode of pHTest")
#                 , Guide.manual_color_key("Line", ["pH4", "pH7"], ["green", "deepskyblue"])
#                 , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                     , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#                 )
#
# pIdgm_meas_4and7 = plot( layer(dgvt_nwd0_ph4, x=:Inwd_4_1_, y=:gm, Geom.line, Theme(default_color=colorant"green", line_width=2pt))
#                 , layer(dgvt_nwd0_ph7, x=:Inwd_4_1_, y=:gm, Geom.line, Theme(line_width=2pt))
#                 , Scale.y_log10
#                 , Scale.x_log10
#                 , Guide.xlabel("ID(A)")
#                 , Guide.ylabel("gm")
#                 # , Guide.title("nw2-12, chip1B, DC Sweep mode of pHTest")
#                 , Guide.manual_color_key("Line", ["pH4", "pH7"], ["green", "deepskyblue"])
#                 , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                     , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#                 )
#
# pIdVg_4and7 = plot(layer(dnw_ph4, x=:Vg_1_1_, y=:Is_3_1_, Geom.line, Theme(line_width=1pt, default_color=colorant"deepskyblue"))
#                 ,  layer(dnw_ph7, x=:Vg_1_1_, y=:Is_3_1_, Geom.line, Theme(line_width=1pt, default_color=colorant"deepskyblue"))
#                     , Scale.y_log10
#                     # , Scale.x_log10
#                     , Guide.xlabel("VG(V)")
#                     , Guide.ylabel("Id(A)")
#                     # , Guide.title("nw2-12, chip1B, DC Sweep mode of gm comparison")
#                     # , Guide.manual_color_key("Line", ["Meas", "NW"], ["green", "deepskyblue"])
#                     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                         , major_label_font_size=18pt, minor_label_font_size=18pt)
#                     )
#
# val = (dnw_ph4[:Is_3_1_] - dnw_ph7[:Is_3_1_]) ./ dnw_ph4[:gm]
# # VgCal = DataFrame()
# p_ph4and7_Vgdiff = plot(x=dnw_ph4[:gm], y= val, Geom.line, Geom.point
#                         , Scale.x_log10
#                         )
# # pIm_4vs7 = plot(layer(dgvt_nwd0_ph4, y=:Im_1_1_, Geom.line, Geom.point)
# #         ,layer(dgvt_nwd0_ph7, y=:Im_1_1_, Geom.line)
# #         )
# pVopi_4vs7 = plot(layer(dgvt_nwd0_ph4, y=:Vopi_2_1_, Geom.line, Geom.point)
#         ,layer(dgvt_nwd0_ph7, y=:Vopi_2_1_, Geom.line)
#         )
#
# # pId_Vopi = plot(
# #               layer(dgvt_nwd0_A[15:51, :], x=:Id_2_1_, y=:Vopi_4_1_, Geom.line, Geom.point, Theme(default_color=colorant"green"))
# #             , layer(dgvt_nwd0_B[28:51, :], x=:Id_2_1_, y=:Vopi_4_1_, Geom.line, Geom.point, Theme(default_color=colorant"maroon"))
# #             , layer(dgvt_nwd0_C[22:51, :], x=:Id_2_1_, y=:Vopi_4_1_, Geom.line, Geom.point, Theme(default_color=colorant"darkkhaki"))
# #             , Guide.yticks(ticks=[0.4:0.2:1, 0.7:0.02:0.88])
# #             , Guide.xlabel("ID(A)")
# #             , Guide.ylabel("Vopi(V)")
# #             , Guide.title("nw1-7, chip1B")
# #             , Scale.x_log10
# #             , Guide.manual_color_key("Line", ["cn=0.82", "cn=0.939", "cn=0.896"], ["green", "maroon", "darkkhaki"])
# #             , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
# #                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
# #             )
# # #
# #
# #
# #
#
#
# # 1223
# Vnwd = dgvt_nwd0_ph7_2[:Vopi_2_1_][1]
# dgvt_nwd0_ph7_2 = readtable("./data/1223/gvt.txt", separator='\t', header=true)
# dgvt_nwd0_ph7_2[:Inwd_4_1_] = dgvt_nwd0_ph7_2[:Inwd_4_1_] * (-1)
# dgvt_nwd0_ph7_2[:Ileak] = (Vnwd - dgvt_nwd0_ph7_2[:Vopi_2_1_]) ./ RTIA
# dgvt_nwd0_ph7_2[:Ibias] = dgvt_nwd0_ph7_2[:Ileak] + dgvt_nwd0_ph7_2[:Inwd_4_1_]
# dgvt_nwd0_ph7_2[:gm_meas] = diff(dgvt_nwd0_ph7_2[:Vopo_3_1_], dgvt_nwd0_ph7_2[:Ibias])
# dgvt_nwd0_ph7_2[:gm] = diff(dgvt_nwd0_ph7_2[:Vopo_3_1_], dgvt_nwd0_ph7_2[:Inwd_4_1_])
# dgvt_nwd0_ph7_2[:gm_error] = (dgvt_nwd0_ph7_2[:gm] - dgvt_nwd0_ph7_2[:gm_meas]) ./ dgvt_nwd0_ph7_2[:gm]
#
#
# pId_Vopi = plot(
#               layer(dgvt_nwd0_ph7_2, y=:Vopi_2_1_, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             , Guide.yticks(ticks=[0.4:0.2:1, 0.7:0.02:0.88])
#             , Guide.xlabel("ID(A)")
#             , Guide.ylabel("Vopi(V)")
#             , Guide.title("nw1-7, chip1B")
#             # , Scale.x_log10
#             , Guide.manual_color_key("Line", ["cn=0.82", "cn=0.939", "cn=0.896"], ["green", "maroon", "darkkhaki"])
#             , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#             )
#
# pIdVg_measdata_7_2 = plot(layer(dgvt_nwd0_ph7_2[2:20, :], x=:Vopo_3_1_, y=:Ibias, Geom.line, Theme(line_width=1pt, default_color=colorant"deepskyblue"))
#                     , layer(dgvt_nwd0_ph7_2[2:20, :], x=:Vopo_3_1_, y=:Inwd_4_1_, Geom.line, Theme(line_width=1pt, default_color=colorant"green"))
#                     , Scale.y_log10
#                     # , Scale.x_log10
#                     , Guide.xlabel("VG(V)")
#                     , Guide.ylabel("Id(A)")
#                     # , Guide.title("nw2-12, chip1B, DC Sweep mode of gm comparison")
#                     # , Guide.manual_color_key("Line", ["Meas", "NW"], ["green", "deepskyblue"])
#                     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                         , major_label_font_size=18pt, minor_label_font_size=18pt)
#                     )
#
# pgmId_measdata_7_2 = plot(layer(dgvt_nwd0_ph7_2[2:20, :], x=:Inwd_4_1_, y=:gm, Geom.line, Theme(line_width=1pt, default_color=colorant"deepskyblue"))
#                     , layer(dgvt_nwd0_ph7_2[2:20, :], x=:Ibias, y=:gm_meas, Geom.line, Theme(line_width=1pt, default_color=colorant"green"))
#                     # , Scale.y_log10
#                     # , Scale.x_log10
#                     , Guide.xlabel("ID(A)")
#                     , Guide.ylabel("gm")
#                     , Guide.title("nw2-12, chip1B, DC Sweep mode of gm comparison")
#                     , Guide.manual_color_key("Line", ["Meas", "NW"], ["green", "deepskyblue"])
#                     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                         , major_label_font_size=18pt, minor_label_font_size=18pt)
#                     )
#
# 2 + 2
#
#
# # Ibias by SourceMeter
#
# dnw_Ib = readtable("./data/1224/nw2-8.txt", separator='\t', header=true)
# dnw_Ib[:Is_3_1_] = dnw_Ib[:Is_3_1_] * (-1)
# dnw_Ib[:gm] = diff(dnw_Ib[:Vg_1_1_], dnw_Ib[:Is_3_1_])
#
# plot_Idgm = plot( layer(dnw_Ib[2:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(default_color=colorant"green", line_width=2pt))
#                 , Scale.y_log10
#                 , Scale.x_log10
#                 , Guide.xlabel("ID(A)")
#                 , Guide.ylabel("gm")
#                 # , Guide.title("nw2-12, chip1B, DC Sweep mode of pHTest")
#                 # , Guide.manual_color_key("Line", ["pH4", "pH7"], ["green", "deepskyblue"])
#                 , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                     , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#                 )
#
# dgvt_nwd0_ph7_v = readtable("./data/1224/gvt_2.txt", separator='\t', header=true)
# dgvt_nwd0_ph7_v_Ib = readtable("./data/1224/gvt_2_Ibcal.txt", separator='\t', header=true)
# dgvt_nwd0_ph7_v[:Inwd_4_1_] = dgvt_nwd0_ph7_v[:Inwd_4_1_] * (-1)
# # dgvt_nwd0_ph7_Ib[:Ileak] = (0.897 - dgvt_nwd0_ph7_Ib[:Vopi_2_1_]) ./ RTIA
#
# dgvt_nwd0_ph7_v_Ib[:Ib_1_1_] = dgvt_nwd0_ph7_v_Ib[:Ib_1_1_] * (-1)
# dgvt_nwd0_ph7_v_Ib[:Ibias_cal] = (dgvt_nwd0_ph7_v_Ib[:Vnwd_3_1_] - dgvt_nwd0_ph7_v_Ib[:Vopi_2_1_]) ./ 108.432e3
#
# dgvt_nwd0_ph7_v[:Ibias_cal] = dgvt_nwd0_ph7_v_Ib[:Ibias_cal]
# dgvt_nwd0_ph7_v[:gm_cal] = diff(dgvt_nwd0_ph7_v[:Vopo_3_1_], dgvt_nwd0_ph7_v[:Ibias_cal])
# dgvt_nwd0_ph7_v[:gm] = diff(dgvt_nwd0_ph7_v[:Vopo_3_1_], dgvt_nwd0_ph7_v[:Inwd_4_1_])
# dgvt_nwd0_ph7_v[:gm_error] = abs((dgvt_nwd0_ph7_v[:gm] - dgvt_nwd0_ph7_v[:gm_cal]) ./ dgvt_nwd0_ph7_v[:gm])
# #
#
# pIbIb = plot(dgvt_nwd0_ph7_v_Ib[(dgvt_nwd0_ph7_v_Ib[:Ibias_cal] .> 0), :], x=:Ib_1_1_, y=:Ibias_cal, Geom.line
#             , Scale.y_log10
#             , Scale.x_log10
#             , Guide.yticks(ticks = [-4:-1:-8, -5.3])
#             , Guide.xticks(ticks = [-9:1:-5, -6.3])
#             )
#
# #
# pgmId_measdata_v = plot(layer(dgvt_nwd0_ph7_v[21:50, :], x=:Ibias_cal, y=:gm, Geom.line, Geom.point, Theme(line_width=3pt, default_color=colorant"deepskyblue"))
#                     , layer(dgvt_nwd0_ph7_v[21:50, :], x=:Ibias_cal, y=:gm_cal, Geom.line, Geom.point, Theme(line_width=3pt, default_color=colorant"green"))
#                     , Scale.y_log10
#                     , Scale.x_log10
#                     , Guide.xlabel("Ibias(A)")
#                     , Guide.ylabel("gm")
#                     , Guide.yticks(ticks = [-4:-1:-8, -6.52])
#                     # , Guide.xticks(ticks = [-4:-1:-8, -5.7])
#                     , Guide.title("nw2-12, chip1B, DC Sweep mode of gm comparison, gm is limited of 300n")
#                     , Guide.manual_color_key("", ["Calculated from Ibias", "Calculated from ID"], ["green", "deepskyblue"])
#                     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                         , major_label_font_size=18pt, minor_label_font_size=18pt)
#                     )
# pIdVg_measdata_v = plot(
#                     #   layer(dgvt_nwd0_ph7_v[(dgvt_nwd0_ph7_v[:Inwd_4_1_] .> 0), ], x=:Vopo_3_1_, y=:Inwd_4_1_, Geom.line, Theme(line_width=1pt, default_color=colorant"deepskyblue"))
#                     # , layer(dgvt_nwd0_ph7_v[dgvt_nwd0_ph7_v[:Ibias_cal] .> 0, :], x=:Vopo_3_1_, y=:Ibias_cal, Geom.line, Theme(line_width=1pt, default_color=colorant"green"))
#                     layer(dgvt_nwd0_ph7_v[21:51, :], x=:Vopo_3_1_, y=:Inwd_4_1_, Geom.point, Geom.line, Theme(line_width=3pt, default_color=colorant"deepskyblue"))
#                   , layer(dgvt_nwd0_ph7_v[21:51, :], x=:Vopo_3_1_, y=:Ibias_cal, Geom.point, Geom.line, Theme(line_width=3pt, default_color=colorant"green"))
#                     # , layer(dgvt_nwd0_ph7_Ib[30:101, :], x=:Ib_1_1_, y=:gm_b, Geom.line, Theme(line_width=1pt, default_color=colorant"maroon"))
#                     , Scale.y_log10
#                     # , Scale.x_log10
#                     , Guide.xlabel("VG(V)")
#                     , Guide.ylabel("I(A)")
#                     , Guide.title("nwB2-12, chip1B, DC Sweep mode, IdVg Plot")
#                     , Guide.manual_color_key("", ["Ibias", "ID"], ["green", "deepskyblue"])
#                     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                         , major_label_font_size=18pt, minor_label_font_size=18pt)
#                     )
#
#
# pgmError = plot(dgvt_nwd0_ph7_v[21:51, :], x=:gm, y=:gm_error, Geom.line, Geom.point
#                 , Scale.y_log10
#                 , Scale.x_log10
#                 , Guide.xlabel("gm")
#                 , Guide.ylabel("gm_diff")
#                 , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                     , major_label_font_size=18pt, minor_label_font_size=18pt)
#                 )
#
# draw(PNG("Fig/gvt/gvt_NWB2_8_Idgm.png", 24cm, 15cm), pgmId_measdata_v)
# draw(PNG("Fig/gvt/gvt_NWB2_8_IdVg.png", 24cm, 15cm), pIdVg_measdata_v)
# draw(PNG("Fig/gvt/gvt_NWB2_8_gmcompare.png", 24cm, 15cm), pgmError)
#
# pVopi_measdata_v = plot(layer(dgvt_nwd0_ph7_v, y=:Vopi_2_1_, Geom.line, Geom.point)
#         # ,layer(dgvt_nwd0_ph7, y=:Vopi_2_1_, Geom.line)
#         )
#
#
#
#
#
#
# # 1226
#
# dnw = readtable("./data/1226/nw.txt", separator='\t', header=true)
# dnw[:Is_3_1_] = dnw[:Is_3_1_] * (-1)
# dnw[:gm] = diff(dnw[:Vg_1_1_], dnw[:Is_3_1_])
#
# plot(dnw, x=:Is_3_1_, y=:gm, Geom.line, Scale.x_log10, Scale.y_log10
#     , Guide.yticks(ticks=[-5:-0.5:-7, -6.1])
#     , Guide.xticks(ticks=[-5:-0.5:-9, -6.25])
#                 )
# # select
# # use 500 at Ib


2 + 2
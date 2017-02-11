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



## 1226

dnw_phA = readtable("./data/1226/nw1-8_t.txt", separator='\t', header=true)
dnw_phA[:Is_3_1_] = dnw_phA[:Is_3_1_] * (-1)
dnw_phA[:gm] = diff(dnw_phA[:Vg_1_1_], dnw_phA[:Is_3_1_])
dnw_phB = readtable("./data/1226/nw1-8_t2.txt", separator='\t', header=true)
dnw_phB[:Is_3_1_] = dnw_phB[:Is_3_1_] * (-1)
dnw_phB[:gm] = diff(dnw_phB[:Vg_1_1_], dnw_phB[:Is_3_1_])

p_IdVg = plot( layer(dnw_phA[2:20, :], y=:Is_3_1_, x=:Vg_1_1_, Geom.line, Theme(default_color=colorant"green", line_width=1pt))
                , layer(dnw_phB[2:21, :], y=:Is_3_1_, x=:Vg_1_1_, Geom.line, Theme(line_width=1pt))
                , Scale.y_log10
                # , Guide.xticks(ticks=[-8:1:-4, -6.26])
                # , Guide.yticks(ticks=[-8:1:-4, -5.7])
                , Guide.xlabel("VG(V)")
                , Guide.ylabel("ID(A)")
                , Guide.title("nwB1-8, chip1B, IdVg sweep")
                , Guide.manual_color_key("Line", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )

p_Idgm = plot( layer(dnw_phA[2:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(default_color=colorant"green", line_width=2pt))
                , layer(dnw_phB[2:21, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(line_width=2pt))
                , Scale.y_log10
                , Scale.x_log10
                # , Guide.xticks(ticks=[-8:1:-4, -6.26])
                # , Guide.yticks(ticks=[-8:1:-4, -5.7])
                , Guide.xlabel("ID(A)")
                , Guide.ylabel("gm")
                , Guide.title("nwB1-8, chip1B, gmId plot of pHTest \n gm is almost same in two differenet pH buffer")
                , Guide.manual_color_key("", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )


p_Idgm = plot( layer(dnw_phA[2:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=2pt))
                , Scale.y_log10
                , Scale.x_log10
                , Guide.xticks(ticks=[-8:1:-4; -6.26])
                , Guide.yticks(ticks=[-8:1:-4; -5.7])
                , Guide.xlabel("ID(A)")
                , Guide.ylabel("gm")
                , Guide.title("nwB1-8, chip1B, gmId plot of pHTest \n The gm = 2u when Id ≈ 550n")
                , Guide.manual_color_key("", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )

vDeltapH = (dnw_phB[:Is_3_1_] - dnw_phA[:Is_3_1_]) ./ dnw_phA[:gm]

p_DeltaV = plot(x=dnw_phA[:Vg_1_1_], y=vDeltapH, Geom.line
                , Guide.xlabel("VG(V)")
                , Guide.ylabel("△V")
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt))


draw(PNG("Fig/pHTest/nwB1-8_ph4and7_IdVg.png", 24cm, 15cm), p_IdVg)
draw(PNG("Fig/pHTest/nwB1-8_ph4and7_Idgm.png", 24cm, 15cm), p_Idgm)
draw(PNG("Fig/pHTest/nwB1-8_FindIDgm_Idgm.png", 24cm, 15cm), p_Idgm)
draw(PNG("Fig/pHTest/pH_DeltaV_nwB1-8.png", 24cm, 15cm), p_DeltaV)


# Ibias = 550nA gm=2u DeltaV = 0.2
dWave = readtable("./data/1226/scope_1.txt", separator='\t', header=true)


p_wave_nwB = plot(layer(dWave, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green"))
            , layer(dWave, x=:x_axis, y=:x2, Geom.line)
            , Guide.xlabel("Time(s)")
            , Guide.ylabel("Vout(V)")
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
            )

draw(PNG("Fig/pHTest/pHTest_wave_nwB1-8.png", 24cm, 15cm), p_wave_nwB)


# # # # # # # # # # GVT Debug # # # # # # # # # # # # # # # # # # # # # #
# nwA2-1
# dgvt_nwB = readtable("./data/1226/gvt1.txt", separator='\t', header=true)
# dgvt_nwB[:Inwd_4_1_] = dgvt_nwB[:Inwd_4_1_] * (-1)
# dgvt_nwB = sort!(dgvt_nwB, cols=:Inwd_4_1_)
# dgvt_nwB[:gm] = diff(dgvt_nwB[:Vopo_3_1_], dgvt_nwB[:Inwd_4_1_])
# dgvt_nwd0_ph7_v_Ib = readtable("./data/1224/gvt_2_Ibcal.txt", separator='\t', header=true)
# dgvt_nwd0_ph7_v_Ib[:Ibias_cal] = (dgvt_nwd0_ph7_v_Ib[:Vnwd_3_1_] - dgvt_nwd0_ph7_v_Ib[:Vopi_2_1_]) ./ 108.432e3
# dgvt_nwB[:Ibias] = dgvt_nwd0_ph7_v_Ib[:Ibias_cal]
# dgvt_nwB[:gm_cal] = diff(dgvt_nwB[:Vopo_3_1_], dgvt_nwB[:Ibias])
#
# # A = DataFrame(x1=[2,1,4,4,6], x2=["a", "b", "c", "d", "e"], x3=[7,5,3,38 , 8])
#
# pIdgm = plot( layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], x=:Ibias, y=:gm, Geom.line, Geom.point)
#             , layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], x=:Ibias, y=:gm_cal, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             , Scale.x_log10
#             , Scale.y_log10
#             , Guide.xticks(ticks=[-7:1:-4, -6.26])
#             , Guide.yticks(ticks=[-7:1:-4, -5.7])
#             )
#
# pIdVg = plot( layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], y=:Inwd_4_1_, x=:Vopo_3_1_, Geom.line, Geom.point)
#             , layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], y=:Ibias, x=:Vopo_3_1_, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             # , Scale.x_log10
#             , Scale.y_log10
#             # , Guide.xticks(ticks=[-7:1:-4, -6.26])
#             # , Guide.yticks(ticks=[-7:1:-4, -5.7])
#             )
# p = plot( layer(dgvt_nwB, y=:gm, Geom.line, Geom.point)
#             , layer(dgvt_nwB, y=:gm_cal, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             # , Scale.x_log10
#             # , Scale.y_log10
#             # , Guide.xticks(ticks=[-7:1:-4, -6.26])
#             # , Guide.yticks(ticks=[-7:1:-4, -5.7])
#             )


# # # # # # # # # # GVT Debug # # # # # # # # # # # # # # # # # # # # # #
# dgvt_nwB = readtable("./data/1226/gvt_2.txt", separator='\t', header=true)
# dgvt_nwB[:Inwd_4_1_] = dgvt_nwB[:Inwd_4_1_] * (-1)
# dgvt_nwB = sort!(dgvt_nwB, cols=:Inwd_4_1_)
# dgvt_nwB[:gm] = diff(dgvt_nwB[:Vopo_3_1_], dgvt_nwB[:Inwd_4_1_])
# dgvt_nwdB_Ib = readtable("./data/1226/gvt_2Ibcal.txt", separator='\t', header=true)
# dgvt_nwdB_Ib[:Ibias_cal] = (dgvt_nwdB_Ib[:Vnwd_3_1_] - dgvt_nwdB_Ib[:Vopi_2_1_]) ./ 108.432e3
# dgvt_nwB[:Ibias] = dgvt_nwdB_Ib[:Ibias_cal]
# dgvt_nwB[:gm_cal] = diff(dgvt_nwB[:Vopo_3_1_], dgvt_nwB[:Ibias])
#
# # A = DataFrame(x1=[2,1,4,4,6], x2=["a", "b", "c", "d", "e"], x3=[7,5,3,38 , 8])
#
# pIdgm = plot( layer(dgvt_nwB[dgvt_nwB[:gm] .> 0, :], x=:Inwd_4_1_, y=:gm, Geom.line, Geom.point)
#             , layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], x=:Ibias, y=:gm_cal, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             , Scale.x_log10
#             , Scale.y_log10
#             , Guide.xticks(ticks=[-7:1:-4, -6.26])
#             , Guide.yticks(ticks=[-7:1:-4, -5.7])
#             )
#
# pIdVg = plot( layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], y=:Inwd_4_1_, x=:Vopo_3_1_, Geom.line, Geom.point)
#             , layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], y=:Ibias, x=:Vopo_3_1_, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             # , Scale.x_log10
#             , Scale.y_log10
#             # , Guide.xticks(ticks=[-7:1:-4, -6.26])
#             # , Guide.yticks(ticks=[-7:1:-4, -5.7])
#             )
# p = plot( layer(dgvt_nwB, y=:gm, Geom.line, Geom.point)
#             , layer(dgvt_nwB, y=:gm_cal, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             # , Scale.x_log10
#             # , Scale.y_log10
#             # , Guide.xticks(ticks=[-7:1:-4, -6.26])
#             # , Guide.yticks(ticks=[-7:1:-4, -5.7])
#             )
#
# dnw = readtable("./data/1226/nwB2-1.txt", separator='\t', header=true)
# dnw[:Is_3_1_] = dnw[:Is_3_1_] * (-1)
# dnw[:gm] = diff(dnw[:Vg_1_1_], dnw[:Is_3_1_])
#
# plot(dnw, x=:Is_3_1_, y=:gm, Geom.line
#     , Guide.yticks(ticks = [-4:-1:-10, log10(200e-9)])
#     , Guide.xticks(ticks = [-4:-1:-10, log10(400e-9)])
#     , Scale.x_log10, Scale.y_log10)
#
# plot(
#       layer(dgvt_nwB, y=:Vopi_2_1_, x=:Inwd_4_1_, Geom.line)
#     # , layer(dnw, y=:Is_3_1_, x=:Vg_1_1_, Geom.line)
#     # , Guide.yticks(ticks = [-4:-1:-10, log10(200e-9)])
#     # , Guide.xticks(ticks = [-4:-1:-10, log10(400e-9)])
#     # , Scale.x_log10
#     # , Scale.y_log10
#     )
#
# dgvt_nwB[:Current_1_1_] = dgvt_nwB[:Current_1_1_] * (-1)
# pIbIb = plot(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], x=:Current_1_1_, y=:Ibias, Geom.line, Scale.x_log10, Scale.y_log10)

# 2 + 2
#

# # # # # # # # # # # GVT Debug # # # # # # # # # # # # # # # # # # # #


# dgvt_nwB = readtable("./data/1226/gvt_5_nwB_3.txt", separator='\t', header=true)
# dgvt_nwB[:Inwd_4_1_] = dgvt_nwB[:Inwd_4_1_] * (-1)
# dgvt_nwB = sort!(dgvt_nwB, cols=:Inwd_4_1_)
# dgvt_nwB[:gm] = diff(dgvt_nwB[:Vopo_3_1_], dgvt_nwB[:Inwd_4_1_])
# dgvt_nwdB_Ib = readtable("./data/1226/gvt_2Ibcal.txt", separator='\t', header=true)
# dgvt_nwdB_Ib[:Ibias_cal] = (dgvt_nwdB_Ib[:Vnwd_3_1_] - dgvt_nwdB_Ib[:Vopi_2_1_]) ./ 108.432e3
# dgvt_nwB[:Ibias] = dgvt_nwdB_Ib[:Ibias_cal]
# dgvt_nwB[:gm_cal] = diff(dgvt_nwB[:Vopo_3_1_], dgvt_nwB[:Ibias])
#
# # A = DataFrame(x1=[2,1,4,4,6], x2=["a", "b", "c", "d", "e"], x3=[7,5,3,38 , 8])
#
# pIdgm = plot( layer(dgvt_nwB[dgvt_nwB[:gm] .> 0, :], x=:Inwd_4_1_, y=:gm, Geom.line, Geom.point)
#             # , layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], x=:Ibias, y=:gm_cal, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             , Scale.x_log10
#             , Scale.y_log10
#             # , Guide.xticks(ticks=[-7:1:-4, -6.26])
#             # , Guide.yticks(ticks=[-7:1:-4, -5.7])
#             )
#
# pIdVg = plot( layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], y=:Inwd_4_1_, x=:Vopo_3_1_, Geom.line, Geom.point)
#             , layer(dgvt_nwB[dgvt_nwB[:Ibias] .> 0, :], y=:Ibias, x=:Vopo_3_1_, Geom.line, Geom.point, Theme(default_color=colorant"green"))
#             # , Scale.x_log10
#             , Scale.y_log10)
#             # , Guide.xticks(ticks=[-7:1:-4, -6.26])
#             # , Guide.yticks(ticks=[-7:1:-4, -5.7])
#


# pHTest Keep

dnwA = readtable("./data/1226/2-1/nw.txt", separator='\t', header=true)
dnwA[:Is_3_1_] = dnwA[:Is_3_1_] * (-1)
dnwA[:gm] = diff(dnwA[:Vg_1_1_], dnwA[:Is_3_1_])

p_nwA_IdVg = plot( layer(dnwA[2:20, :], x=:Vg_1_1_, y=:Is_3_1_, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=2pt))
                , Scale.y_log10
                # , Scale.x_log10
                # , Guide.xticks(ticks = [-5:-1:-10; -6.05])
                # , Guide.yticks(ticks = [-5:-1:-9; -5.7])
                , Guide.xlabel("VG(V)")
                , Guide.ylabel("ID(A)")
                , Guide.title("nwA2-1, IdVg")
                # , Guide.manual_color_key("Line", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )



p_nwA_Idgm = plot( layer(dnwA[2:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=2pt))
                , Scale.y_log10
                , Scale.x_log10
                , Guide.xticks(ticks = [-5:-1:-10; -6.05])
                , Guide.yticks(ticks = [-5:-1:-9; -5.7])
                , Guide.xlabel("ID(A)")
                , Guide.ylabel("gm")
                , Guide.title("nwA2-1, gmId plot of pHTest \n The gm = 2u when Id ≈ 900n")
                # , Guide.manual_color_key("Line", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )

dWave_nwA = readtable("./data/1226/scope_waveNWA2-1.txt", separator='\t', header=true)

p_wave_nwA = plot(layer(dWave_nwA, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green"))
            , layer(dWave_nwA, x=:x_axis, y=:x2, Geom.line)
            , Guide.xlabel("Time(s)")
            , Guide.ylabel("Vout(V)")
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
            )

draw(PNG("Fig/pHTest/pHTest_IdVg_nwA2-1.png", 24cm, 15cm), p_nwA_IdVg)
draw(PNG("Fig/pHTest/pHTest_Idgm_nwA2-1_FindIDgm_Idgm.png", 24cm, 15cm), p_nwA_Idgm)
draw(PNG("Fig/pHTest/pHTest_wave_nwA2-1.png", 24cm, 15cm), p_wave_nwA)




#
dnwA2 = readtable("./data/1227/nwA3-3.txt", separator='\t', header=true)
dnwA2[:Is_3_1_] = dnwA2[:Is_3_1_] * (-1)
dnwA2[:gm] = diff(dnwA2[:Vg_1_1_], dnwA2[:Is_3_1_])
p_nwA2_Idgm = plot( layer(dnwA2[2:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=2pt))
                , Scale.y_log10
                , Scale.x_log10
                , Guide.xticks(ticks = [-5:-1:-10; -6.22])
                , Guide.yticks(ticks = [-5:-1:-9; -5.7])
                , Guide.xlabel("ID(A)")
                , Guide.ylabel("gm")
                , Guide.title("nwA3-2, chip1A, gmId plot of pHTest \n The gm = 2u when Id ≈ 900n")
                , Guide.manual_color_key("Line", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )
# draw(PNG("Fig/pHTest/nwA3-2_FindIDgm_Idgm.png", 24cm, 15cm), p_nwA2_Idgm)

# dWave_nwA2 = readtable("./data/1226/scope_waveNWA2-1.txt", separator='\t', header=true)
#
# p_wave_nwA2 = plot(layer(dWave_nwA2, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green"))
#             , layer(dWave_nwA2, x=:x_axis, y=:x2, Geom.line)
#             , Guide.xlabel("Time(s)")
#             , Guide.ylabel("Vout(V)")
#             , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#             )
#
# draw(PNG("Fig/pHTest/pHTest_wave_nwA3-2.png", 24cm, 15cm), p_wave_nwA2)



dnwA3_3A = readtable("./data/1227/nwA3-3_2.txt", separator='\t', header=true)
dnwA3_3A[:Is_3_1_] = dnwA3_3A[:Is_3_1_] * (-1)
dnwA3_3A[:gm] = diff(dnwA3_3A[:Vg_1_1_], dnwA3_3A[:Is_3_1_])

dnwA3_3B = readtable("./data/1227/nwA3-3_2pHB.txt", separator='\t', header=true)
dnwA3_3B[:Is_3_1_] = dnwA3_3B[:Is_3_1_] * (-1)
dnwA3_3B[:gm] = diff(dnwA3_3B[:Vg_1_1_], dnwA3_3B[:Is_3_1_])

vDeltapH2 = (dnwA3_3B[:Is_3_1_] - dnwA3_3A[:Is_3_1_]) ./ dnwA3_3B[:gm]

p_DeltaV2 = plot(x=dnwA3_3B[:Vg_1_1_], y=vDeltapH2, Geom.line
                , Guide.xlabel("VG(V)")
                , Guide.ylabel("△V")
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt))

p_Idgm2 = plot( layer(dnwA3_3A[2:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(default_color=colorant"green", line_width=2pt))
                , layer(dnwA3_3B[2:21, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(line_width=2pt))
                , Scale.y_log10
                , Scale.x_log10
                # , Guide.xticks(ticks=[-8:1:-4, -6.26])
                # , Guide.yticks(ticks=[-8:1:-4, -5.7])
                , Guide.xlabel("ID(A)")
                , Guide.ylabel("gm")
                , Guide.title("nwA3-3, chip1B, gmId plot of pHTest \n gm is almost same in two differenet pH buffer")
                , Guide.manual_color_key("Line", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )

p_IdVg2 = plot( layer(dnwA3_3A[2:20, :], y=:Is_3_1_, x=:Vg_1_1_, Geom.line, Theme(default_color=colorant"green", line_width=1pt))
                , layer(dnwA3_3B[2:21, :], y=:Is_3_1_, x=:Vg_1_1_, Geom.line, Theme(line_width=1pt))
                , Scale.y_log10
                # , Guide.xticks(ticks=[-8:1:-4, -6.26])
                # , Guide.yticks(ticks=[-8:1:-4, -5.7])
                , Guide.xlabel("VG(V)")
                , Guide.ylabel("ID(A)")
                , Guide.title("nwB1-8, chip1B, IdVg sweep")
                , Guide.manual_color_key("Line", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )

draw(PNG("Fig/pHTest/pH_DeltaV2_nwA3-3.png", 24cm, 15cm), p_DeltaV2)
#




# nwA1-2


dnwA1_2A = readtable("./data/1228/nwA1-2_.txt", separator='\t', header=true)
dnwA1_2A[:Is_3_1_] = dnwA1_2A[:Is_3_1_] * (-1)
dnwA1_2A[:gm] = diff(dnwA1_2A[:Vg_1_1_], dnwA1_2A[:Is_3_1_])

dnwA1_2B = readtable("./data/1228/nwA1-2_B.txt", separator='\t', header=true)
dnwA1_2B[:Is_3_1_] = dnwA1_2B[:Is_3_1_] * (-1)
dnwA1_2B[:gm] = diff(dnwA1_2B[:Vg_1_1_], dnwA1_2B[:Is_3_1_])

p_Idgm3 = plot( layer(dnwA1_2A[4:20, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(default_color=colorant"green", line_width=2pt))
                , layer(dnwA1_2B[2:21, :], x=:Is_3_1_, y=:gm, Geom.line, Theme(line_width=2pt))
                , Scale.y_log10
                , Scale.x_log10
                , Guide.xticks(ticks=[-8:1:-4; -6.46])
                , Guide.yticks(ticks=[-8:1:-4; -5.7])
                , Guide.xlabel("ID(A)")
                , Guide.ylabel("gm")
                , Guide.title("nwA1-2, gmId plot of pHTest \n gm is almost same in two differenet pH buffer \n The gm = 2u when Id ≈ 350n")
                , Guide.manual_color_key("Line", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )

p_IdVg3 = plot( layer(dnwA1_2A[4:20, :], y=:Is_3_1_, x=:Vg_1_1_, Geom.line, Theme(default_color=colorant"green", line_width=1pt))
                , layer(dnwA1_2B[2:21, :], y=:Is_3_1_, x=:Vg_1_1_, Geom.line, Theme(line_width=1pt))
                , Scale.y_log10
                # , Guide.xticks(ticks=[-8:1:-4, -6.26])
                # , Guide.yticks(ticks=[-8:1:-4, -5.7])
                , Guide.xlabel("VG(V)")
                , Guide.ylabel("ID(A)")
                , Guide.title("nwA1-2, IdVg sweep")
                , Guide.manual_color_key("Line", ["pHA", "pHB"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )

vDeltapH3 = (dnwA1_2B[:Is_3_1_] - dnwA1_2A[:Is_3_1_]) ./ dnwA1_2B[:gm]

p_DeltaV3 = plot(x=dnwA1_2B[:Vg_1_1_], y=vDeltapH3, Geom.line
                , Guide.xlabel("VG(V)")
                , Guide.ylabel("△V")
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt))


dWave_nwA_2 = readtable("./data/1228/scope_3.txt", separator='\t', header=true)

p_wave_nwA_2 = plot(layer(dWave_nwA_2, x=:x_axis, y=:x1, Geom.line)
            , layer(dWave_nwA_2, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"green"))
            , Guide.xlabel("Time(s)")
            , Guide.ylabel("Vout(V)")
            , Guide.yticks(ticks=collect(0.8:0.2:1.6))
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
            )

draw(PNG("Fig/pHTest/pHTest_IdVg_nwA1-2.png", 24cm, 15cm), p_IdVg3)
draw(PNG("Fig/pHTest/pHTest_Idgm_nwA1-2.png", 24cm, 15cm), p_Idgm3)
draw(PNG("Fig/pHTest/pHTest_wave_nwA1-2.png", 24cm, 15cm), p_wave_nwA_2)
draw(PNG("Fig/pHTest/pH_DeltaV_nwA1-2.png", 24cm, 15cm), p_DeltaV3)










#
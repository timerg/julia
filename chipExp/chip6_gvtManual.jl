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



# # # 1003
# input = readtable("./data/1003/gvt_manual.txt", header=true, separator='\t')
# input[:Id_cal] = (input[:Im]) ./ 4
# dnw = readtable("./data/1003/nw2-7.txt", header=true, separator='\t')
# dnw[:Id_mean] = mean_onRow(dnw, [2, 4])
# dnw[:Id_diff] = diff(dnw[:Vg_1_1_], dnw[:Id_mean])
# dnw[:Id_min] = operate_row(min, dnw[:Id_2_1_], dnw[:Id_2_2_])
# dnw[:Id_max] = operate_row(max, dnw[:Id_2_1_], dnw[:Id_2_2_])
# dnw[:gm] = diff(dnw[:Vg_1_1_], dnw[:Id_mean])
#
# dnw2 = readtable("./data/1003/nw2-7_2.txt", header=true, separator='\t')
# dnw2[:Id_mean] = mean_onRow(dnw2, [2, 4, 6, 8])
# dnw2[:Id_diff] = diff(dnw2[:Vg_1_1_], dnw2[:Id_mean])
# dnw2[:Id_min] = operate_row(min, dnw2[:Id1], dnw2[:Id2], dnw2[:Id3], dnw2[:Id4])
# dnw2[:Id_max] = operate_row(max, dnw2[:Id1], dnw2[:Id2], dnw2[:Id3], dnw2[:Id4])
#
#
# plot0 = Gadfly.plot(dnw[dnw[:gm] .> 0, :], x = "Id_mean", y = "gm", Geom.line, Geom.point
#               , Guide.xlabel("Id(A)")
#               , Guide.ylabel("transconductance(Id/Vg)")
#               , Scale.x_log10
#               , Scale.y_log10
#               , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#             )
# draw(PNG("Fig/1003/1003_gmId.png", 15cm, 16cm), plot0)
#
#
# plot1 = Gadfly.plot(layer(dnw[dnw[:Id_mean] .> 1e-8, :], x = "Vg_1_1_", y = "Id_mean", ymin = "Id_min", ymax = "Id_max", Geom.line, Geom.errorbar)
#           , layer(input, x = "Vopo", y = "Id_cal", Geom.point, Geom.line, Theme(default_color=colorant"green"))
#           , Guide.xlabel("Vg(V)")
#           , Guide.ylabel("Id(A)")
#           , Guide.title("Id = Im / 4, which match IdVg for Id > 2u")
#           , Guide.manual_color_key("Line", ["MeasData", "NwSweep"], ["green", "deepskyblue"])
#           , Scale.y_log10
#           , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#               , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#         )
#
#
# draw(PNG("Fig/1003/1003_gvtMeas.png", 30cm, 16cm), plot1)
# plot1_2 = Gadfly.plot(layer(dnw[(dnw[:Id_mean] .> 1e-8) & (dnw[:Id_mean] .< 2e-6), :], x = "Vg_1_1_", y = "Id_mean", ymin = "Id_min", ymax = "Id_max", Geom.line, Geom.errorbar)
#           , layer(input[input[:Id_cal] .< 2e-6, :], x = "Vopo", y = "Id_cal", Geom.point, Geom.line, Theme(default_color=colorant"green"))
#           , Guide.xlabel("Vg(V)")
#           , Guide.ylabel("Id(A)")
#           , Guide.title("Id = Im / 4, which match IdVg for Id > 2u")
#           , Guide.manual_color_key("Line", ["MeasData", "NwSweep"], ["green", "deepskyblue"])
#         #   , Scale.y_log10
#           , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#               , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#         )
#
#
#
# # 1004
# input = readtable("./data/1004/1004_gvt_vimp.txt", header=true, separator='\t')
# input[:Id_cal] = (input[:Im]) ./ 4
# dnw = readtable("./data/1004/nw2-6.txt", header=true, separator='\t')
# dnw[:Id_mean] = mean_onRow(dnw, [2, 4, 6, 8])
# dnw[:Id_diff] = diff(dnw[:Vg_1_1_], dnw[:Id_mean])
# dnw[:Id_min] = operate_row(min, dnw[:Id1], dnw[:Id2], dnw[:Id3], dnw[:Id4])
# dnw[:Id_max] = operate_row(max, dnw[:Id1], dnw[:Id2], dnw[:Id3], dnw[:Id4])
#
# plot2 = Gadfly.plot(layer(dnw[dnw[:Id_mean] .> 1e-7, :], x = "Vg_1_1_", y = "Id_mean", ymin = "Id_min", ymax = "Id_max", Geom.line, Geom.errorbar)
#           , layer(input, x = "Vopo", y = "Id_cal", Geom.point, Geom.line, Theme(default_color=colorant"green"))
#           , layer(input, x = "Vopo", y = "Inw", Geom.point, Geom.line, Theme(default_color=colorant"maroon"))
#           , Guide.xlabel("Vg(V)")
#           , Guide.ylabel("Id(A)")
#           , Guide.title("measuredata1")
#           , Guide.manual_color_key("Line", ["MeasData_Id", "MeasData_Id=Im/4", "NwSweep"], ["maroon", "green", "deepskyblue"])
#           , Scale.y_log10
#           , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#               , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#         )
#
# # plot2_vimp = Gadfly.plot(input, x = "Im", y = "Vimp", Geom.line, Geom.point
# #           , Guide.xlabel("Im(A)")
# #           , Guide.ylabel("Vimp(V)")
# #           , Guide.title("measuredata1")
# #           , Scale.x_log10
# #           , Guide.manual_color_key("Line", ["MeasData_Id", "MeasData_Id=Im/4", "NwSweep"], ["maroon", "green", "deepskyblue"])
# #           , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
# #               , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
# #         )
#
#
# draw(PNG("Fig/1004/1004_gvtMeas.png", 30cm, 16cm), plot2)
# #
# input = readtable("./data/1004/1004_gvt_vimp2.txt", header=true, separator='\t')
# input[:Id_cal] = (input[:Im]) ./ 3
# input[:Iimp] = (input[:Vimp] - 0.76) ./ 92257
# input[:Id_compensate] = (input[:Inw] - input[:Iimp])
#
# plot3 = Gadfly.plot(layer(input, x = "Vopo", y = "Id_cal", Geom.point, Geom.line, Theme(default_color=colorant"green"))
#                   , layer(input, x = "Vopo", y = "Inw", Geom.point, Geom.line, Theme(default_color=colorant"maroon"))
#                   , Guide.xlabel("Vg(V)")
#                   , Guide.ylabel("Id(A)")
#                   , Guide.title("measuredata2: (After Nw was hit by -5v)")
#                   , Guide.manual_color_key("Line", ["MeasData", "MeasData_Id=Im/3"], ["maroon", "green"])
#                   , Scale.y_log10
#                   , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                       , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#                 )
#
# plot3_vimp = Gadfly.plot(input, x = "Im", y = "Vimp", Geom.line, Geom.point
#           , Guide.xlabel("Im(A)")
#           , Guide.ylabel("Vimp(V)")
#           , Guide.title("measuredata1")
#           , Scale.x_log10
#           , Guide.manual_color_key("Line", ["MeasData_Id", "MeasData_Id=Im/4", "NwSweep"], ["maroon", "green", "deepskyblue"])
#           , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#               , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#         )
#
# draw(PNG("Fig/1004/1004_gvtMeas_IdvsIm.png", 30cm, 16cm), plot3)
# draw(PNG("Fig/1004/1004_gvtMeas_vimp.png", 30cm, 16cm), plot3_vimp)
#
# plot4 = Gadfly.plot(layer(input[input[:Id_compensate] .> 0, :], x = "Im", y = "Id_compensate", Geom.line, Geom.point, Theme(default_color=colorant"maroon"))
#                   , layer(input, x = "Im", y = "Inw", Geom.line, Geom.point)
#                   , layer(input, x = "Im", y = "Iimp", Geom.line, Geom.point, Theme(default_color=colorant"green"))
#                   , Guide.manual_color_key("Line", ["Inwd", "Inwd - Iimp(Id_compensate)", "Iimp"], ["deepskyblue", "maroon", "green"])
#                   , Guide.ylabel("Id(A)")
#                   , Guide.xlabel("Im(A)")
#                   , Scale.x_log10
#                   , Scale.y_log10
#                   , Guide.title("measuredata2: A constant leakage current \n(After Nw was hit by -5v)")
#                   , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                       , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#                 )
# plot4_fit = Gadfly.plot(layer(input[input[:Id_compensate] .> 0, :], x = "Im", y = "Inw", Geom.line, Geom.point, Theme(default_color=colorant"green"))
#                       , layer(x = input[:Im], y = input[:Im] ./ 4, Geom.point, Geom.line)
#                       , layer(input[input[:Id_compensate] .> 0, :], x = "Im", y = "Id_compensate", Geom.point, Geom.line, Theme(default_color=colorant"maroon"))
#                   , Guide.manual_color_key("Line", ["Inw", "c", "Im / 4"], ["green", "maroon", "deepskyblue"])
#                   , Scale.x_log10
#                   , Scale.y_log10
#                   , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                       , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#                 )
# draw(PNG("Fig/1004/1004_gvtMeas_IdImIimp.png", 30cm, 16cm), plot4)
#
#
#
# plot5 = Gadfly.plot(layer(x = input[:Im], y = input[:Im] ./ input[:Id_compensate] , Geom.line, Geom.point, Theme(default_color=colorant"green"))
#                   , layer(x = input[:Im], y = input[:Im] ./ input[:Inw] , Geom.line, Geom.point)
#                   , Scale.x_log10
#                   , Guide.yticks(ticks=[1, 3, 4, 20])
#                   , Guide.xlabel("Im(A)")
#                   , Guide.ylabel("Ratio: Im/Id_compensate")
#                   , Guide.manual_color_key("Line", ["Inw", "Inw - Iimp"], ["deepskyblue", "green"])
#                   , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                         , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#                 )
# draw(PNG("Fig/1004/1004_gvtMeas_mirror.png", 30cm, 16cm), plot5)
#
#
# # 1008
# input = readtable("./data/1008/gvt_manual_vimp.txt", header=true, separator='\t')
# input[:Id_cal] = (input[:Im]) ./ 4
# input[:Id_compensate] = input[:Id_cal] - (0.78 - input[:Vimp]) ./ 92257
#
# dnw = readtable("./data/1008/nw1-8_4.txt", header=true, separator='\t')
# dnw[:Id_mean] = mean_onRow(dnw, [2, 4, 6, 8])
# dnw[:Id_diff] = diff(dnw[:Vg1], dnw[:Id_mean])
# dnw[:Id_min] = operate_row(min, dnw[:Id1], dnw[:Id2], dnw[:Id3], dnw[:Id4])
# dnw[:Id_max] = operate_row(max, dnw[:Id1], dnw[:Id2], dnw[:Id3], dnw[:Id4])
# dnw[:gm] = diff(dnw[:Vg1], dnw[:Id_mean])
#
#
# plot6 = Gadfly.plot(layer(dnw[dnw[:Id_mean] .> 0, :], x = "Vg1", y = "Id_mean", ymin = "Id_min", ymax = "Id_max", Geom.line, Geom.errorbar)
#           , layer(input, x = "Vopo", y = "Id_cal", Geom.line, Theme(default_color=colorant"green"))
#           , layer(input, x = "Vopo", y = "Id_compensate", Geom.line, Theme(default_color=colorant"maroon"))
#           , Guide.xlabel("Vg(V)")
#           , Guide.ylabel("Id(A)")
#           , Guide.title("Id = Im / 4, which match IdVg for Id > 2u")
#           , Guide.manual_color_key("Line", ["MeasData", "NwSweep"], ["green", "deepskyblue"])
#           , Scale.y_log10
#           , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#               , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#         )
#
# plot7 = Gadfly.plot(input, x = "Im", y = "Vimp", Geom.line
#           , Guide.xlabel("Vg(V)")
#           , Guide.ylabel("Vimp(V)")
#           , Guide.title("Id = Im / 4, which match IdVg for Id > 2u")
#           , Guide.manual_color_key("Line", ["MeasData", "NwSweep"], ["green", "deepskyblue"])
#           , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#               , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#         )



# 1021
input = readtable("./data/1024/gvt_manual.txt", header=true, separator='\t')
input[:Id_cal] = (input[:Im]) ./ 3

dnw = readtable("./data/1024/nw3-10_vds=0.9.txt", header=true, separator='\t')
dnw[:Id_mean] = mean_onRow(dnw, [2, 4])
dnw[:Id_diff] = diff(dnw[:Vg_1_1_], dnw[:Id_mean])
dnw[:Id_min] = operate_row(min, dnw[:Id_2_1_], dnw[:Id_2_2_])
dnw[:Id_max] = operate_row(max, dnw[:Id_2_1_], dnw[:Id_2_2_])
dnw[:gm] = diff(dnw[:Vg_1_1_], dnw[:Id_mean])

dnw_manual = readtable("./data/1024/nw3-10_manual.txt", header=true, separator='\t')
dnw_delay8s = readtable("./data/1024/nw3-10_vds=0.9_delya=8s.txt", header=true, separator='\t')

# It seems meas delay of nw sweep should > 8s
# dnw sweep vds = 0.9, where chip is 0.923, so the convex closed to 2.5 should be cause of that (vds eddefct is more clear as Id increase)
plot8 = Gadfly.plot(layer(dnw_delay8s[(dnw_delay8s[:Id_2_1_] .> 1e-7) & (dnw_delay8s[:Id_2_1_] .< 3e-6), :], x = "Vg_1_1_", y = "Id_2_1_", Geom.line, Geom.point)
                  , layer(input, x = "Vopo", y = "Id_cal", Geom.line, Geom.point, Theme(default_color=colorant"green"))
                  , layer(input, x = "Vopo", y = "Id", Geom.line, Geom.point, Theme(default_color=colorant"maroon"))
                  , Scale.y_log10
                  , Guide.xlabel("Vg(V)")
                  , Guide.ylabel("Vg(V)")
                  , Guide.title("1024_GvtMeasure")
                  , Guide.manual_color_key("Line", ["NwMeas", "Id_cal(Im / 3)", "Id"], ["deepskyblue", "green", "maroon"])
                  , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                      , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )

draw(PNG("Fig/1024/1024_gvtMeas_mirror.png", 30cm, 16cm), plot8)














#
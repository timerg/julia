using Gadfly
using Cairo
using RDatasets
# using CurveFit

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

# nwd1; nw3-6
dcvm_10_ = readtable("./data/1130/CVM_1B_ch0_LonRoff_delay=8000.txt", separator='\t', header=true)
dcvm_100 = readtable("./data/1130/CVM_1B_ch0_LonRon_delay=8000.txt", separator='\t', header=true)

dcvm_10_[:Id_1_1_] = dcvm_10_[:Id_1_1_] * (-1)
dcvm_100[:Id_1_1_] = dcvm_100[:Id_1_1_] * (-1)


pvg_vopi = plot(
              layer(dcvm_10_, x="Vg_3_1_", y="vopi_4_1_", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
            , layer(dcvm_100, x="Vg_3_1_", y="vopi_4_1_", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , Guide.yticks(ticks=[0:0.5:2, 0.82])
            , Guide.ylabel("Vopi")
            , Guide.xlabel("VG")
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )
pvg_Id = plot(
              layer(dcvm_10_, x="Vg_3_1_", y="Id_1_1_", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
            , layer(dcvm_100, x="Vg_3_1_", y="Id_1_1_", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt)
            )
#
pId_vopi = plot(
              layer(dcvm_10_, x="Id_1_1_", y="vopi_4_1_", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
             layer(dcvm_100, x="Id_1_1_", y="vopi_4_1_", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
            , Guide.ylabel("Vopi")
            , Guide.xlabel("ID")
            , Scale.x_log10
            , Guide.manual_color_key("mode", ["LonRoff", "LonRon"], ["deepskyblue", "green"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )
#
pId_vopa = plot(layer(dcvm_10_, x="Id_1_1_", y="Vopa_2_1_", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , layer(dcvm_100, x="Id_1_1_", y="Vopa_2_1_", Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
            , Guide.ylabel("Vopa")
            , Guide.xlabel("ID")
            , Guide.yticks(ticks=[0:0.3:2.7, 1.1])
            , Guide.manual_color_key("mode", ["LonRoff", "LonRon"], ["deepskyblue", "maroon"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )
dcvm_10_[:fitVopoa] = (dcvm_10_[:vopi_4_1_] - 0.72) * 6
dcvm_100[:fitVopoa] = (dcvm_100[:vopi_4_1_] - 0.8) * 10
#
pvopi_vopa = plot(
              layer(dcvm_10_, x="vopi_4_1_", y="Vopa_2_1_", Geom.line, Geom.point, Theme(default_color=colorant"deepskyblue", line_width=1pt))
            , layer(dcvm_100, x="vopi_4_1_", y="Vopa_2_1_", Geom.line, Geom.point, Theme(default_color=colorant"maroon", line_width=1pt))
            , layer(dcvm_10_, x="vopi_4_1_", y="fitVopoa", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=0.5pt))
            , layer(dcvm_100, x="vopi_4_1_", y="fitVopoa", Geom.line, Theme(default_color=colorant"maroon", line_width=0.5pt))
            , Guide.ylabel("Vopa")
            , Guide.xlabel("Vopi")
            , Guide.yticks(ticks=[0:0.3:2.7, 1.1])
            , Guide.xticks(ticks=[0.5:0.1:1.5])
            , Guide.manual_color_key("mode: (vds, ampRate)", ["LonRoff: (0.72, 6)", "LonRon: (0.8, 10)"], ["deepskyblue", "maroon"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )

            dcvm_10_[:diff] = diff(dcvm_10_[:vopi_4_1_], dcvm_10_[:Vopa_2_1_])
            dcvm_100[:diff] = diff(dcvm_100[:vopi_4_1_], dcvm_100[:Vopa_2_1_])

draw(PNG("Fig/Chip1/CVM_1B_vopivopa.png", 24cm, 20cm), pvopi_vopa)


pdiff = plot(
              layer(dcvm_10_, x="vopi_4_1_", y="diff", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , layer(dcvm_100, x="vopi_4_1_", y="diff", Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
            , Guide.ylabel("diff")
            , Guide.xlabel("Vopi")
            , Guide.manual_color_key("mode: (vds, ampRate)", ["LonRoff: (0.8163, 8)", "LonRon: (0.8163, 14)"], ["deepskyblue", "maroon"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )

# 1203
# Measure seperately
dcvm_seperately = DataFrame(vopi=readtable("./data/1203/vopi_2.txt", separator='\t', header=true)[:vopi_2]
                    , vopa=readtable("./data/1203/vopa_2.txt", separator='\t', header=true)[:vopa_2])


pcvm_seperately = plot(dcvm_seperately, x=:vopi, y=:vopa, Geom.line)

pcvm_seperately_diff = plot(x=dcvm_seperately[:vopi], y=diff(dcvm_seperately[:vopi], dcvm_seperately[:vopa]), Geom.line)

dcvm_together = readtable("./data/1203/together.txt", separator='\t', header=true)
pcvm_together = plot( layer(dcvm_together, x=:Vopi_4, y=:vopa_2, Geom.line, Geom.point)
                    , layer(dcvm_seperately, x=:vopi, y=:vopa, Geom.line)
                    )

dcvm_hsol = readtable("./data/1203/cvm_100_highrsol.txt", separator='\t', header=true)
dcvm_hsol[:diff] = diff(dcvm_hsol[:Vopi_4_1_],dcvm_hsol[:vopa_2_1_] )
dcvm_hsol[:fitVopoa] = (dcvm_hsol[:Vopi_4_1_] - 0.802) * 30
pcvm_rsol = plot( layer(dcvm_hsol, x=:Vopi_4_1_, y=:vopa_2_1_, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=1pt))
                ,  layer(dcvm_hsol, x=:Vopi_4_1_, y=:fitVopoa, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=0.5pt))
                , layer(dcvm_seperately, x=:vopi, y=:vopa, Geom.line, Theme(default_color=colorant"maroon", line_width=1pt))
                , layer(dcvm_together, x=:Vopi_4, y=:vopa_2, Geom.line, Theme(default_color=colorant"firebrick", line_width=1pt))
                , Guide.yticks(ticks=[0:0.5:2.5, 1.1])
                , Guide.xticks(ticks=[0.5:0.1:1.0, 0.802])
                    )

plot_hsol_diff = plot(dcvm_hsol, x=:Vopi_4_1_, y=:diff, Geom.line
                    , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                                     , major_label_font_size=18pt, minor_label_font_size=18pt)
                    )
draw(PNG("Fig/cvm/1203_high_resol_100fold.png", 30cm, 16cm), plot_hsol_diff)

# # pcvmb = plot(layer(x=dcvmb[:Vg], y=(dcvmb[:Vc]/110000 + dcvmb[:Im_0_112_]/4)
# #                 , Geom.line, Theme(default_color=colorant"green", line_width=3pt)),
# #              layer(dnw2, x="Vg_1_2_", y="Id_2_2_"
# #                 , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt)),
# #              layer(dnw2, x="Vg_1_1_", y="Id_2_1_"
# #                 , Geom.line, Theme(default_color=colorant"darkred", line_width=3pt)),
# #              Guide.manual_color_key("Line", ["MeasData", "NwSweep1", "NwSweep2"], ["green", "deepskyblue", "darkred"]),
# #              Guide.ylabel("Id(A)"), Guide.xlabel("Vg(V)"),
# #              Guide.title("Im = 41.5u; Inwb = 10.3u"),
# #              Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
# #                  , major_label_font_size=18pt, minor_label_font_size=18pt
# #                  )
# #     )
# #
# 1+1
# draw(PNG("Fig/cvm/1123_RonLoff&RonLon_Id2u_vz11_nwvopi.png", 30cm, 16cm), pnw_vopi)
# draw(PNG("Fig/cvm/1123_RonLoff&RonLon_Id2u_vz11_nwvopa.png", 30cm, 16cm), pnw_vopa)
# draw(PNG("Fig/cvm/1123__RonLoff&RonLon_Id2u_vz11_vopivopa.png", 30cm, 16cm), pvopi_vopa)
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
dcvm1 = readtable("./data/1123/CVM_nwdA1_Inw_vopi_vopa_rm401k_vm211mV_LonRoff_vds0.8163.txt", separator='\t', header=true)
dcvm2a = readtable("./data/1123/CVM_nwdA1_Inw_vopi_vopa_Im2u_LonRoff_vds0.8163_vz11.txt", separator='\t', header=true)
dcvm2b = readtable("./data/1123/CVM_nwdA1_Inw_vopi_vopa_Im2u_LonRon_vds0.8163_vz11.txt", separator='\t', header=true)

dcvm2b[:Inw_1_1_] = dcvm2b[:Inw_1_1_] * (-1)
dcvm2a[:Inw_1_1_] = dcvm2a[:Inw_1_1_] * (-1)
dcvm1[:Inw_1_1_] = dcvm1[:Inw_1_1_] * (-1)


pvg_vopi = plot(layer(dcvm1, x="Vg_3_1_", y="vopi_4_1_"
                , Geom.line, Theme(default_color=colorant"green", line_width=3pt))
            , layer(dcvm2a, x="Vg_3_1_", y="vopi_4_1_"
                , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , layer(dcvm2b, x="Vg_3_1_", y="vopi_4_1_"
                , Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
            , Guide.yticks(ticks=[0:0.5:1.5, 0.816])
            , Guide.ylabel("Vopi")
            , Guide.xlabel("VG")
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )
pvg_nw = plot(layer(dcvm1, x="Vg_3_1_", y="Inw_1_1_"
                , Geom.line, Theme(default_color=colorant"green", line_width=3pt))
            , layer(dcvm2a, x="Vg_3_1_", y="Inw_1_1_"
                , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , layer(dcvm2b, x="Vg_3_1_", y="Inw_1_1_"
                , Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt)
            )

pnw_vopi = plot(
              layer(dcvm2a, x="Inw_1_1_", y="vopi_4_1_"
                , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=1pt))
            # , layer(dcvm1, x="Inw_1_1_", y="vopi_4_1_"
            #     , Geom.line, Theme(default_color=colorant"green", line_width=3pt))
            , layer(dcvm2b, x="Inw_1_1_", y="vopi_4_1_"
                , Geom.point, Theme(default_color=colorant"maroon", line_width=3pt))
            , Guide.ylabel("Vopi")
            , Guide.xlabel("ID")
            , Scale.x_log10
            , Guide.manual_color_key("mode", ["LonRoff", "LonRon"], ["deepskyblue", "maroon"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )

pnw_vopa = plot(layer(dcvm2a, x="Inw_1_1_", y="Vopa_2_1_"
                , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , layer(dcvm2b, x="Inw_1_1_", y="Vopa_2_1_"
                , Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
            , Guide.ylabel("Vopa")
            , Guide.xlabel("ID")
            , Guide.yticks(ticks=[0:0.3:3.3, 1.1])
            , Guide.manual_color_key("mode", ["LonRoff", "LonRon"], ["deepskyblue", "maroon"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )

dcvm2a[:fitVopoa] = (dcvm2a[:vopi_4_1_] - 0.8163) * 8
dcvm2b[:fitVopoa] = (dcvm2b[:vopi_4_1_] - 0.8163) * 14

pvopi_vopa = plot(layer(dcvm2a, x="vopi_4_1_", y="Vopa_2_1_"
                , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
            , layer(dcvm2b, x="vopi_4_1_", y="Vopa_2_1_"
                , Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
            , layer(dcvm2a, x="vopi_4_1_", y="fitVopoa"
                , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=1pt))
            , layer(dcvm2b, x="vopi_4_1_", y="fitVopoa"
                , Geom.line, Theme(default_color=colorant"maroon", line_width=1pt))
            , Guide.ylabel("Vopa")
            , Guide.xlabel("Vopi")
            , Guide.yticks(ticks=[0:0.3:3.3, 1.1])
            , Guide.manual_color_key("mode: (vds, ampRate)", ["LonRoff: (0.8163, 8)", "LonRon: (0.8163, 14)"], ["deepskyblue", "maroon"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt)
            )



#
# pcvmb = plot(layer(x=dcvmb[:Vg], y=(dcvmb[:Vc]/110000 + dcvmb[:Im_0_112_]/4)
#                 , Geom.line, Theme(default_color=colorant"green", line_width=3pt)),
#              layer(dnw2, x="Vg_1_2_", y="Id_2_2_"
#                 , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt)),
#              layer(dnw2, x="Vg_1_1_", y="Id_2_1_"
#                 , Geom.line, Theme(default_color=colorant"darkred", line_width=3pt)),
#              Guide.manual_color_key("Line", ["MeasData", "NwSweep1", "NwSweep2"], ["green", "deepskyblue", "darkred"]),
#              Guide.ylabel("Id(A)"), Guide.xlabel("Vg(V)"),
#              Guide.title("Im = 41.5u; Inwb = 10.3u"),
#              Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                  , major_label_font_size=18pt, minor_label_font_size=18pt
#                  )
#     )
#
1+1
draw(PNG("Fig/cvm/1123_RonLoff&RonLon_Id2u_vz11_nwvopi.png", 30cm, 16cm), pnw_vopi)
draw(PNG("Fig/cvm/1123_RonLoff&RonLon_Id2u_vz11_nwvopa.png", 30cm, 16cm), pnw_vopa)
draw(PNG("Fig/cvm/1123__RonLoff&RonLon_Id2u_vz11_vopivopa.png", 30cm, 16cm), pvopi_vopa)
using Gadfly
using Cairo
using RDatasets
using CurveFit

dcvma = readtable("./data/0828/CVM_a.txt", separator='\t', header=true)
dnw = readtable("./data/0828/nw.txt", separator='\t', header=true)

dcvmb = readtable("./data/0828/CVM_b.txt", separator='\t', header=true)
dnw2 = readtable("./data/0828/nw2.txt", separator='\t', header=true)

pcvma = plot(layer(x=dcvma[:Vg], y=(dcvma[:Vc]/110000 + dcvma[:Im_0_287_]/4)
                , Geom.line, Theme(default_color=colorant"green", line_width=3pt)),
             layer(dnw, x="Vg_1_2_", y="Id_2_2_"
                , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt)),
             layer(dnw, x="Vg_1_1_", y="Id_2_1_"
                , Geom.line, Theme(default_color=colorant"darkred", line_width=3pt)),
             Guide.manual_color_key("Line", ["MeasData", "NwSweep1", "NwSweep2"], ["green", "deepskyblue", "darkred"]),
             Guide.ylabel("Id(A)"), Guide.xlabel("Vg(V)"),
             Guide.title("Im = 577n; Inwb = 145n"),
             Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt
                 )
    )

pcvmb = plot(layer(x=dcvmb[:Vg], y=(dcvmb[:Vc]/110000 + dcvmb[:Im_0_112_]/4)
                , Geom.line, Theme(default_color=colorant"green", line_width=3pt)),
             layer(dnw2, x="Vg_1_2_", y="Id_2_2_"
                , Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt)),
             layer(dnw2, x="Vg_1_1_", y="Id_2_1_"
                , Geom.line, Theme(default_color=colorant"darkred", line_width=3pt)),
             Guide.manual_color_key("Line", ["MeasData", "NwSweep1", "NwSweep2"], ["green", "deepskyblue", "darkred"]),
             Guide.ylabel("Id(A)"), Guide.xlabel("Vg(V)"),
             Guide.title("Im = 41.5u; Inwb = 10.3u"),
             Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt
                 )
    )

draw(PNG("Fig/0828_CVM_Meas.png", 15cm, 16cm), pcvma)
draw(PNG("Fig/0828_CVM_Meas2.png", 15cm, 16cm), pcvmb)
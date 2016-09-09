using Gadfly
using RDatasets
using Cairo
using CurveFit

intputa03 = readtable("./data/0823/nw_a_0_1.txt", separator='\t', header=true)
intputa02 = readtable("./data/0823/nw_a_0_2.txt", separator='\t', header=true)
intputb01 = readtable("./data/0823/nw_b_0_1.txt", separator='\t', header=true)

# Inw Sweep. wi/wo trimpVmeter attached
inwWo = readtable("./data/0823/sweepInw_noVoMeas.txt", separator='\t', header=true)
inwWi = readtable("./data/0823/sweepInw_wiVoMeas_2.txt", separator='\t', header=true)
inwWi_l = readtable("./data/0823/sweepInw_wiVoMeas_1_leak.txt", separator='\s', header=true)

# Without Nw append to find current of Bias pmos. This remove all possible side effect from source Meter
dnoNwd = readtable("./data/0823/Meas_noNwdAppend.txt", separator='\t', header=true)

da03 = DataFrame(Inwd = intputa03[:, 2], Im = intputa03[:, 3], Vimp = intputa03[:, 4], name = "a03")
da02 = DataFrame(Inwd = intputa02[:, 2], Im = intputa02[:, 3], Vimp = intputa02[:, 4], name = "a02")
db01 = DataFrame(Inwd = intputb01[:, 3], Im = intputb01[:, 4], Vimp = intputb01[:, 5], name = "b01")

dinwWo = DataFrame(Vnwd = inwWo[:, 2], Inwd = inwWo[:, 3], name = "InwWo")
dinwWi = DataFrame(Vnwd = inwWi[:, 2], Inwd = inwWi[:, 3], Im = inwWi[:, 4], Vimp = inwWi[:, 5], name = "InwWi")
# dinwWi = DataFrame(Vnwd = inwWi_l[:, 2], Inwd = inwWi_l[:, 3], Im = inwWi_l[:, 4], Vimp = inwWi_l[:, 5], ILeak = inwWi_l[:, 6], name = "InwWi")

# Fitting da01
# linear_fit(x, y): find (a, b) of y = ax + b
fa03 = [0 0]
fa03 = linear_fit(Vector(da03[:Inwd]), Vector(da03[:Vimp]))
funca03(x) = fa03[1] + (fa03[2] * 1.1) * x

fa02 = [0 0]
fa02 = linear_fit(Vector(da02[:Inwd]), Vector(da02[:Vimp]))
funca02(x) = fa02[1] + (fa02[2] * 1.1) * x
r_a02 = fa02[2] * 1.1


dinwWi[:Iimp] = (dinwWi[:Vnwd] + dinwWi[:Vimp]) / r_a02
dinwWi[:Ip] = (dinwWi[:Inwd] - dinwWi[:Iimp])
# dinwWi[:Ip] = (dinwWi[:Inwd] - (dinwWi[:Iimp] - dinwWi[:ILeak]))

pInw = plot(layer(dinwWo, x="Inwd", y="Vnwd", Geom.line, color="name"),
            layer(dinwWi, x="Inwd", y="Vnwd", Geom.line, color="name"),
            layer(dinwWi, x="Inwd", y="Vimp", Geom.line, Theme(default_color=colorant"grey")),
            Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
        )

pIm_Ip = plot(layer(dinwWi, y="Im", x=linspace(1, 400), Geom.line, Theme(default_color=colorant"green")),
              layer(dinwWi, y="Ip", x=linspace(1, 400), Geom.line,  Theme(default_color=colorant"darkgoldenrod")),
              Guide.manual_color_key("Line", ["Im", "Ip"], ["green", "darkgoldenrod"]),
              Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
              , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
        )

pInw_Iimp = plot(layer(dinwWi, y="Inwd", x=linspace(1, 400), Geom.line,  Theme(default_color=colorant"deepskyblue")),
                 layer(dinwWi, y="Iimp", x=linspace(1, 400), Geom.line,  Theme(default_color=colorant"brown")),
                 Guide.manual_color_key("Line", ["Inwd", "Iimp"], ["deepskyblue", "brown"]),
                 Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
                )

pMirror_acc = plot(x=linspace(1, 400), y=(dinwWi[:Ip] ./ dinwWi[:Im]), Geom.line)

pa02_log = plot(layer(da02, x="Inwd", y="Vimp", Geom.line, Theme(default_color=colorant"green"), order=2),
            layer(da02, x="Inwd", y=funca02(da02[:Inwd]), Geom.line, order=1),
            Scale.x_log10,
            Guide.manual_color_key("Line", ["Vimp", "fitCurve"], ["green", "deepskyblue"]),
            Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
        )

pa03 = plot(layer(da03, x="Inwd", y="Vimp", Geom.line, Theme(default_color=colorant"green"), order=2),
            layer(da03, x="Inwd", y=funca02(da03[:Inwd]),  Geom.line, order=1),
            Guide.manual_color_key("Line", ["Vimp", "fitCurve"], ["green", "deepskyblue"]),
            Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
        )

pa03_log = plot(layer(da03, x="Inwd", y="Vimp", Geom.line, Theme(default_color=colorant"green"), order=2),
            layer(da03, x="Inwd", y=funca02(da03[:Inwd]),  Geom.line, order=1),
            Scale.x_log10,
            Guide.manual_color_key("Line", ["Vimp", "fitCurve"], ["green", "deepskyblue"]),
            Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
        )

pnwd = plot(layer(dinwWi, x=:Inwd, y=:Vnwd, Geom.line, color="name"),
            layer(dinwWo, x=:Inwd, y=:Vnwd, Geom.line, color="name"),
            Guide.title("wi/wo Probe at transimpedance output affect point nwd"),
            Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
        )

pnoNwd_vnwd = plot(x=abs(dnoNwd[:Imp_]), y=dnoNwd[:Vnwd]
                , Geom.line
                , Scale.x_log10
                , Guide.ylabel("Vnwd")
                , Guide.xlabel("Im")
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
            )
pnoNwd_ratio = plot(x=abs(dnoNwd[:Imp_]), y=abs(dnoNwd[:Ratio])
                , Geom.line
                , Scale.x_log10
                , Guide.xlabel("Im")
                , Guide.ylabel("Ratio")
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=3pt)
            )

pnoNwd_im = plot(layer(x=abs(dnoNwd[:Im]), y=abs(dnoNwd[:Imp_]), Geom.line),
                 layer(x=abs(dnoNwd[:Im]), y=abs(dnoNwd[:Im])/4.2, Geom.line, Theme(default_color=colorant"darkgoldenrod")),
        )

pnoNwd_IVimp = plot(x=abs(dnoNwd[:Im]), y=(dnoNwd[:Vcross] + dnoNwd[:Vnwd]), Geom.line)



draw(PNG("fit_a02_log.png", 24cm, 16cm), pa02_log)
draw(PNG("fit_a03_log.png", 24cm, 16cm), pa03_log)
draw(PNG("fit_a03.png", 24cm, 16cm), pa03)

# Wrong measurement(cause by source meter and resistance related feedback failure)
# draw(PNG("Im_Ip.png", 24cm, 16cm), pIm_Ip)
# draw(PNG("Inw_Iimp.png", 24cm, 16cm), pInw_Iimp)
# draw(PNG("Vnwd_Compare.png", 24cm, 16cm), pnwd)

draw(PNG("MirrorRatio_useRv.png", 18cm, 12cm), pnoNwd_ratio)
draw(PNG("vnwd_useRv.png", 18cm, 5cm), pnoNwd_vnwd)


# Use Plots
# using Plots
#
# Plots.plot(dnoNwd[:Imp_], line = (:steppre, :dot, :arrow, 0.5, 4, :red))




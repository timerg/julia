using Gadfly
using RDatasets
using Cairo
using CurveFit

# Rm=7.3k: Im=24u
input01 = readtable("./data/0913/findR_2_rm=7100.txt", header=true, separator='\t')
p01_vnwd = plot(input01, y="Vnwd_2_1_", Geom.line, Guide.yticks(ticks=[0.75:0.01:0.85]))
input01 = input01[(input01[:Vnwd_2_1_] .> 0.78) & (input01[:Vnwd_2_1_] .< 0.85), :]
input01[:Vcross] = abs(input01[:Vo_3_1_] - input01[:Vnwd_2_1_])

pinput01 = plot(input01, x="Vcross", y="Inwd_2_1_", Geom.line)

# nwd0

f01 = [0 0]
frame = (:)
f01 = linear_fit(Vector(input01[:Vcross][frame]), Vector(input01[:Inwd_2_1_][frame]))
f01[2] = 1/f01[2] # (Bias Pmos current, 1/R)
title = "R = " * (string(round(f01[2])))
input01[:fitI] = f01[1] + input01[:Vcross] / f01[2]
pinput01_fit = plot(layer(input01, x="Vcross", y="Inwd_2_1_", Geom.line)
                    , layer(input01, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green"))
                    , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
                    , Guide.title(title)
                    , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
                    , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )



# Rm=50k: Im=4.82u
input02 = readtable("./data/0913/findR_1_rm=50k.txt", header=true, separator='\t')
# p02_vnwd = plot(input02, y="Vnwd_2_1_", Geom.line, Guide.yticks(ticks=[0.75:0.01:0.85]))
input02 = input02[(input02[:Vnwd_2_1_] .> 0.79) & (input02[:Vnwd_2_1_] .< 0.85), :]
input02[:Vcross] = abs(input02[:Vo_3_1_] - input02[:Vnwd_2_1_])

f02 = [0 0]
frame02 = (:)
f02 = linear_fit(Vector(input02[:Vcross][frame02]), Vector(input02[:Inwd_2_1_][frame02]))
# f02[2] = f02[2] * 0.9
f02[2] = 1/f02[2] # (Bias Pmos current, 1/R)
title02 = "R = " * (string(round(f02[2])))
input02[:fitI] = f02[1] + input02[:Vcross] / f02[2]
pinput02_fit = plot(layer(input02, x="Vcross", y="Inwd_2_1_", Geom.line)
                    , layer(input02, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green"))
                    , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
                    , Guide.title(title02)
                    , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
                    , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )

# 0916
    # nwd0
input03 = readtable("./data/0916/findR_nwd0_Rm50k.txt", header=true, separator='\t')
input03[:Vcross] = abs(input03[:Vo_3_1_] - input03[:Vnwd_2_1_])
f03 = [0 0]
frame03 = (:)
f03 = linear_fit(Vector(input03[:Vcross][frame03]), Vector(input03[:Inwd_2_1_][frame03]))
f03[2] = 1/f03[2] # (Bias Pmos current, 1/R)
title03 = "R = " * (string(round(f03[2])))
input03[:fitI] = f03[1] + input03[:Vcross] / f03[2]

pinput03_fit = plot(layer(input03, x="Vcross", y="Inwd_2_1_", Geom.line)
                    , layer(input03, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green"))
                    , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
                    , Guide.title(title03)
                    , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
                    , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )

    # nwd4
input04 = readtable("./data/0916/findR_nwd4_Rm50k.txt", header=true, separator='\t')
input04[:Vcross] = abs(input04[:Vo_3_1_] - input04[:Vnwd_2_1_])
f04 = [0 0]
frame04 = (:)
f04 = linear_fit(Vector(input04[:Vcross][frame04]), Vector(input04[:Inwd_2_1_][frame04]))
f04[2] = 1/f04[2] # (Bias Pmos current, 1/R)
title04 = "R = " * (string(round(f04[2])))
input04[:fitI] = f04[1] + input04[:Vcross] / f04[2]

pinput04_fit = plot(layer(input04, x="Vcross", y="Inwd_2_1_", Geom.line)
                    , layer(input04, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green"))
                    , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
                    , Guide.title(title04)
                    , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
                    , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )


#

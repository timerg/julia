using Gadfly
using RDatasets
using Cairo
using CurveFit

# nwd0

    # Im=805u
input01 = readtable("./data/0920/findR_Im=805n.txt", header=true, separator='\t')
# input01 = input01[(input01[:Vnwd_2_1_] .> 0.78) & (input01[:Vnwd_2_1_] .< 0.85), :]
input01[:Vcross] = (input01[:Vo_3_1_] + input01[:Vnwd_2_1_])
f01 = [0 0]
frame = (:)
f01 = linear_fit(Vector(input01[:Vcross][frame]), Vector(input01[:Inwd_2_1_][frame]))
f01[2] = 1/f01[2] # (Bias Pmos current, 1/R)
title = "R = " * (string(round(f01[2])))
input01[:fitI] = f01[1] + input01[:Vcross] / f01[2]
pinput01 = plot(input01, x="Vcross", y="Inwd_2_1_", Geom.line
            # , Guide.xticks(ticks = [1e-6:1e-6:10e-6])
            , layer(input01, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green"))
            , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
            , Guide.title(title)
            , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )

    # Im=49.2u
input02 = readtable("./data/0920/findR_Im=49.2u.txt", header=true, separator='\t')
input02[:Vcross] = (input02[:Vo_3_1_] + input02[:Vnwd_2_1_])
f02 = [0 0]
frame = (:)
f02 = linear_fit(Vector(input02[:Vcross][frame]), Vector(input02[:Inwd_2_1_][frame]))
f02[2] = 1/f02[2] # (Bias Pmos current, 1/R)
title = "R = " * (string(round(f02[2])))
input02[:fitI] = f02[1] + input02[:Vcross] / f02[2]
pinput02 = plot(input02, x="Vcross", y="Inwd_2_1_", Geom.line
            # , Guide.xticks(ticks = [1e-6:1e-6:10e-6])
            , layer(input02, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green"))
            , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
            , Guide.title(title)
            , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )

    # Im=510u
input03 = readtable("./data/0920/findR_Im=510n.txt", header=true, separator='\t')
input03[:Vcross] = (input03[:Vo_3_1_] + input03[:Vnwd_2_1_])
f03 = [0 0]
frame = (:)
f03 = linear_fit(Vector(input03[:Vcross][frame]), Vector(input03[:Inwd_2_1_][frame]))
f03[2] = 1/f03[2] # (Bias Pmos current, 1/R)
title = "R = " * (string(round(f03[2])))
input03[:fitI] = f03[1] + input03[:Vcross] / f03[2]
pinput03 = plot(input03, x="Vcross", y="Inwd_2_1_", Geom.line
            # , Guide.xticks(ticks = [1e-6:1e-6:10e-6])
            , layer(input03, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green"))
            , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
            , Guide.title(title)
            , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )
# nwd4
    # Im = 8u
input04 = readtable("./data/0921/nwd4_findR.txt", header=true, separator='\t')
input04[:Vcross] = (input04[:Vo_3_1_] + input04[:Vnwd_2_1_])
f04 = [0 0]
frame = (:)
f04 = linear_fit(Vector(input04[:Vcross][frame]), Vector(input04[:Inwd_2_1_][frame]))
f04[2] = 1/f04[2] # (Bias Pmos current, 1/R)
title = "R = " * (string(round(f04[2])))
input04[:fitI] = f04[1] + input04[:Vcross] / f04[2]
pinput04 = plot(input04, x="Vcross", y="Inwd_2_1_", Geom.line
            # , Guide.xticks(ticks = [1e-6:1e-6:10e-6])
            , layer(input04, x="Vcross", y="fitI", Geom.line, Theme(default_color=colorant"green"))
            , Guide.ylabel("Id(A)"), Guide.xlabel("Vcross(V)")
            , Guide.title(title)
            , Guide.manual_color_key("Line", ["Fit", "Id"], ["green", "deepskyblue"])
            , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )


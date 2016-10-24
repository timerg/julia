using Gadfly
using RDatasets
using Cairo


# nwd0
vwd_nwd0 = 0.85 # (from ./data/0913/findR_2_rm=7100.txt)
R = 86000
input = readtable("./data/0920/mirror_sweep.txt", header=true, separator='\t')
input[:Inwd] = ((vwd_nwd0 - input[:Vo_3_1_]) / R)
input[:ratio] = input[:Im_2_1_] ./ input[:Inwd]
#
pImId = plot(input, x="Im_2_1_", y="Inwd", Geom.line)
#
pratio = plot(input, x="Im_2_1_", y="ratio", Geom.line
            , Scale.x_log10, Scale.y_continuous(minvalue=0, maxvalue=7)
            , Guide.yticks(ticks=[1:5, 5:5:10]))
#
#
pVo = plot(input, x="Im_2_1_", y="Vo_3_1_", Geom.line
            # , Guide.xticks(ticks=[30:10:200])
            )



# nwd4

    # Vcross
R = 86000
input02 = readtable("./data/0921/nwd4_mirror2.txt", header=true, separator='\t')
input02[:Inwd] = (input02[:Vcross_3_1_] / R)
input02[:ratio] = input02[:Im_2_1_] ./ input02[:Inwd]


pImId02 = plot(input02, x="Im_2_1_", y="Inwd", Geom.line, Geom.point)

pratio02 = plot(input02[(input02[:ratio] .< 10) & (input02[:ratio] .> (-10)), :], x="Im_2_1_", y="ratio", Geom.line
            , Scale.x_log10, Scale.y_continuous(minvalue=0, maxvalue=7)
            , Guide.yticks(ticks=[1:5, 5:5:10]))


pVo02 = plot(input02, x="Im_2_1_", y="Vcross_3_1_", Geom.line
            # , Guide.xticks(ticks=[30:10:200])
            )


    # Vimp
R = 85000
vwd_nwd3 = 0.81
input03 = readtable("./data/0921/nwd4_mirror_vimp.txt", header=true, separator='\t')
input03[:Inwd] = ((vwd_nwd3 - input03[:Vimp_3_1_])/ R)
input03[:ratio] = input03[:Im_2_1_] ./ input03[:Inwd]


pImId03 = plot(input03, x="Im_2_1_", y="Inwd", Geom.line, Geom.point)

pratio03 = plot(input03[(input03[:ratio] .< 10) & (input03[:ratio] .> (-10)), :], x="Im_2_1_", y="ratio", Geom.line
            , Scale.x_log10, Scale.y_continuous(minvalue=0, maxvalue=7)
            , Guide.yticks(ticks=[1:5, 5:5:10]))


pVo03 = plot(input03, x="Im_2_1_", y="Vimp_3_1_", Geom.line
            # , Guide.xticks(ticks=[30:10:200])
            )
# Compare: measure way: Vimp vs Vcross by Inwd
pcompare_cross_I = plot(layer(input02, x="Im_2_1_", y="Inwd"
                        , Geom.point, Geom.line, Theme(default_color=colorant"deepskyblue"))
                    , layer(input03, x="Im_2_1_", y="Inwd"
                        , Geom.point, Geom.line, Theme(default_color=colorant"green"))
                    , Scale.x_log10
                    , Guide.manual_color_key("Line", ["MeasOn: Vcross", "MeasOn: Vimp"], ["deepskyblue", "green"])
                    )
# Compare: measure way: Vimp vs Vcross by Ratio
pcompare_cross_ratio = plot(layer(input02[(input02[:ratio] .< 10) & (input02[:ratio] .> (-10)), :], x="Im_2_1_", y="ratio"
                        , Geom.line, Theme(default_color=colorant"deepskyblue"))
                    , layer(input03[(input03[:ratio] .< 10) & (input03[:ratio] .> (-10)), :], x="Im_2_1_", y="ratio"
                        , Geom.line, Theme(default_color=colorant"green"))
                    , Guide.manual_color_key("Line", ["MeasOn: Vcross", "MeasOn: Vimp"], ["deepskyblue", "green"])
                    )

pcompare_cross_I


# if Im > 50uA, Vnwd > 1V

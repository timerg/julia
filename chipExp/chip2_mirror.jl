using Gadfly
using RDatasets
using Cairo


# Assume
    # vwd_nwd0 = 0.82 (from ./data/0913/findR_2_rm=7100.txt)
    # R = 70k

input = readtable("./data/0913/mirror.txt", header=true, separator='\t')
input[:Im_2_1_] = abs(input[:Im_2_1_])
input[:Inwd] = abs((input[:Vo_3_1_] - 0.82) / 66748)
input[:ratio] = input[:Im_2_1_] ./ input[:Inwd]

pImId = plot(input, x="Im_2_1_", y="Inwd", Geom.line)

pratio = plot(input, x="Im_2_1_", y="ratio", Geom.line
            , Scale.x_log10, Scale.y_continuous(minvalue=0, maxvalue=7)
            , Guide.yticks(ticks=[1:5, 5:5:10]))


pVo = plot(y=input[:Vo_3_1_][30:200], Geom.line, Guide.xticks(ticks=[30:10:200]))




# Directly Bias Current into Im (No Variance R)
    # Measure Vimp & Vnwd (seperated)
Rnwd0 = 72000
input2 = readtable("./data/0916/mirror_nwd0_biasIm.txt", header=true, separator='\t')
input2_vnwd = readtable("./data/0916/mirror_nwd0_biasIm_Vnwd.txt", header=true, separator='\t')
input2[:Im_2_1_] = abs(input2[:Im_2_1_])
input2[:Ibias] = (input2_vnwd[:Vnwd_3_1_] - input2[:Vimp_3_1_]) / Rnwd0
input2[:ratio] = input2[:Im_2_1_] ./ input2[:Ibias]

pVimp = plot(input2, x="Im_2_1_", y="Vimp_3_1_", Geom.line
            )

pratio = plot(input2, x="Im_2_1_", y="ratio", Geom.line, Geom.point
            , Scale.x_log10, Scale.y_continuous(minvalue=0, maxvalue=7)
            , Guide.yticks(ticks=[1:5, 5:5:10])
            )

    # Measure Vcross
input3 = readtable("./data/0916/mirror_nwd1_biasIm_Vcross.txt", header=true, separator='\t')
input3[:Im_2_1_] = abs(input3[:Im_2_1_])
input3[:Ibias] = input3[:Vcross_3_1_] / Rnwd0
input3[:ratio] = input3[:Im_2_1_] ./ input3[:Ibias]
pratio_Vcross = plot(input3, x="Im_2_1_", y="ratio", Geom.line, Geom.point
            , Scale.x_log10, Scale.y_continuous(minvalue=0, maxvalue=7)
            , Guide.yticks(ticks=[1:5, 5:5:10])
            )











#
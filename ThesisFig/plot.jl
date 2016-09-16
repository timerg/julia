# This file is just for test. The output for thesis use "plot_Plots.jl" instead 

using Gadfly
using DataFrames
using Cairo
using Interpolations


function itparray(itp, as)
    l = length(as)
    output = zeros(l)
    for i = 1 : l
        output[i] = itp[as[i]]
    end
    return output
end

function garray(itp, as :: Array)
    l = length(as)
    output = zeros(l)
    for i = 1 : l
        output[i] = gradient(itp, as[i])
    end
    return output
end

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

dIdVg = readtable("./data/IdVg_1030_2-7&2-8_PBS.txt", separator='\t', header=true)
dIdVf = readtable("./data/IdVsurface_1030_2-7&2-8_PBS_Vds=1v.txt", separator='\t', header=true)
# dIdVf = readtable("./data/IdVsurface_1030_2-7&2-8_PBS_Vg=2v.txt", separator='\t', header=true)

itp_Vg_Id_2_8_2 = interpolate(dIdVg[:Id2_8_2_2_], BSpline(Cubic(Line())), OnGrid())
itp_Vg_Vg_2_8_2 = interpolate(dIdVg[:Vg_1_2_], BSpline(Cubic(Line())), OnGrid())
itp_Vg_dev_2_8_2 = interpolate(diff(dIdVg[:Vg_1_2_], dIdVg[:Id2_8_2_2_]), BSpline(Cubic(Line())), OnGrid())
itp_Vf_Id_2_8_2 = interpolate(dIdVf[:Id2_8_2_2_], BSpline(Cubic(Line())), OnGrid())
itp_Vf_Vg_2_8_2 = interpolate(dIdVf[:Vsurface_3_2_], BSpline(Cubic(Line())), OnGrid())
itp_Vf_dev_2_8_2 = interpolate(diff(dIdVf[:Vsurface_3_2_], dIdVf[:Id2_8_2_2_]), BSpline(Cubic(Line())), OnGrid())


as = [1:0.1:size(dIdVg, 1)]
dIdVg_dev = DataFrame(Vg=itparray(itp_Vg_Vg_2_8_2, as), Id=itparray(itp_Vg_Id_2_8_2, as), Id_dev=itparray(itp_Vg_dev_2_8_2, as), name="IdVg_nw2-8(2)")
dIdVf_dev = DataFrame(Vg=itparray(itp_Vf_Vg_2_8_2, as), Id=itparray(itp_Vf_Id_2_8_2, as), Id_dev=itparray(itp_Vf_dev_2_8_2, as), name="IdVf_nw2-8(2)")

# plot(dIdVg, x="Vg_1_2_", y=diff(dIdVg[:Vg_1_2_], dIdVg[:Id2_8_2_2_]), Geom.line, Geom.point)
pIddev = plot(layer(dIdVg_dev[dIdVg_dev[:Id_dev].>0, :], x="Vg", y="Id_dev", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
     , layer(dIdVf_dev[dIdVf_dev[:Id_dev].>0, :], x="Vg", y="Id_dev", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
     , Scale.y_log10
     , Guide.manual_color_key("Lines", ["Front-Gate", "Back-Gate"], ["green", "deepskyblue"])
     , Guide.ylabel("Derivative(Id)"), Guide.xlabel("Vg(V)")
     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
         , major_label_font_size=18pt, minor_label_font_size=18pt
         )
     )

 pId = plot(layer(dIdVg_dev[dIdVg_dev[:Id_dev].>0, :], x="Vg", y="Id", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
      , layer(dIdVf_dev[dIdVf_dev[:Id_dev].>0, :], x="Vg", y="Id", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
      , Scale.y_log10
      , Guide.manual_color_key("Lines", ["Front-Gate", "Back-Gate"], ["green", "deepskyblue"])
      , Guide.ylabel("Derivative(Id)"), Guide.xlabel("Vg(V)")
      , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
          , major_label_font_size=18pt, minor_label_font_size=18pt
          )
      )

draw(SVG("../../nthu-master-thesis/images/FgBg_Compare_Id.svg", 18cm, 12cm), pId)
draw(SVG("../../nthu-master-thesis/images/FgBg_Compare_Id_dev.svg", 18cm, 12cm), pIddev)




## Draw Id-gbs_vds


dIdgbs_005v = readtable("./data/1030/IdVsurface_1030_2-7&2-8_PBS_Vds=0.5v.txt", separator='\t', header=true)
dIdgbs_005v[:line] = "Vds=0.5v"
dIdgbs_075v = readtable("./data/1030/IdVsurface_1030_2-7&2-8_PBS_Vds=0.75v.txt", separator='\t', header=true)
dIdgbs_075v[:line] = "Vds=0.75v"
dIdgbs_125v = readtable("./data/1030/IdVsurface_1030_2-7&2-8_PBS_Vds=1.25v.txt", separator='\t', header=true)
dIdgbs_125v[:line] = "Vds=1.25v"
dIdgbs_150v = readtable("./data/1030/IdVsurface_1030_2-7&2-8_PBS_Vds=1.5v.txt", separator='\t', header=true)
dIdgbs_150v[:line] = "Vds=1.5v"

pIdgbs_Vd = plot(layer(dIdgbs_005v, x="Id2_8_2_2_", y=diff(dIdgbs_005v[:Vsurface_3_2_], dIdgbs_005v[:Id2_8_2_2_]), color="line", Geom.line, Geom.point)
        , layer(dIdgbs_075v, x="Id2_8_2_2_", y=diff(dIdgbs_075v[:Vsurface_3_2_], dIdgbs_075v[:Id2_8_2_2_]), color="line", Geom.line, Geom.point)
        , layer(dIdgbs_125v, x="Id2_8_2_2_", y=diff(dIdgbs_125v[:Vsurface_3_2_], dIdgbs_125v[:Id2_8_2_2_]), color="line", Geom.line, Geom.point)
        , layer(dIdgbs_150v, x="Id2_8_2_2_", y=diff(dIdgbs_150v[:Vsurface_3_2_], dIdgbs_150v[:Id2_8_2_2_]), color="line", Geom.line, Geom.point)
        # , Guide.xticks(ticks=[10.0^(-6), 2e-6], label=false)
        # , Guide.xticks(ticks=[10.0^(-6), 2e-7], label=true)
        , Scale.x_log10
        , Scale.y_log10
        , Guide.ylabel("Derivative(Id)"), Guide.xlabel("Id(A)")
        , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
            , major_label_font_size=18pt, minor_label_font_size=18pt
            )
        )








#
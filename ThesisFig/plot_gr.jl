using Plots
using DataFrames
using Interpolations

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

gr()

pIddev = plot([dIdVg_dev[:Vg][20:201] dIdVf_dev[:Vg][20:201]]
            , [dIdVg_dev[:Id_dev][20:201] dIdVf_dev[:Id_dev][20:201]]
            # [dIdVg_dev[dIdVg_dev[:Id_dev].>0, :][:Vg] dIdVf_dev[dIdVf_dev[:Id_dev].>0, :][:Vg]]
            #             , [dIdVg_dev[dIdVg_dev[:Id_dev].>0, :][:Id_dev] dIdVf_dev[dIdVf_dev[:Id_dev].>0, :][:Id_dev]]
            , yscale = :log10
            , xlabel = "VG(V)"
            , ylabel = "Id(A)"
            , yticks = [-7 : 1 : -4]
            , linestyle = :solid
            , linecolor = [colorant"green" colorant"deepskyblue"]
            , linewidth = 2
            , ylims = ((10.0^-7), (10.0^-4))
            , label = ["Back-Gate" "Floating-Gate"]
            , marker = ([:c :cross], 7, [colorant"green" colorant"deepskyblue"])
            # , markersize = 100
            , markerstrokewidth = 0
            , legend = :none
            , size = (600, 300)
            , fmt = :svg

            )

pId = plot([dIdVg_dev[:Vg][20:201] dIdVf_dev[:Vg][20:201]]
            , [dIdVg_dev[:Id][20:201] dIdVf_dev[:Id][20:201]]
            # [dIdVg_dev[dIdVg_dev[:Id_dev].>0, :][:Vg] dIdVf_dev[dIdVf_dev[:Id_dev].>0, :][:Vg]]
            #             , [dIdVg_dev[dIdVg_dev[:Id_dev].>0, :][:Id_dev] dIdVf_dev[dIdVf_dev[:Id_dev].>0, :][:Id_dev]]
            , yscale = :log10
            , xlabel = "VG(V)"
            , ylabel = "Id(A)"
            , yticks = [-7 : 1 : -4]
            , linestyle = :solid
            , linecolor = [colorant"green" colorant"deepskyblue"]
            , linewidth = 2
            , ylims = ((10.0^-7), (10.0^-4))
            , label = ["Back-Gate" "Floating-Gate"]
            , marker = ([:c :cross], 7, [colorant"green" colorant"deepskyblue"])
            # , markersize = 100
            , markerstrokewidth = 0
            , legend = :bottomleft
            , size = (600, 300)
            , fmt = :svg

            )

 # pId = plot(layer(dIdVg_dev[dIdVg_dev[:Id_dev].>0, :], x="Vg", y="Id", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
 #      , layer(dIdVf_dev[dIdVf_dev[:Id_dev].>0, :], x="Vg", y="Id", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
 #      , Scale.y_log10
 #      , Guide.manual_color_key("Lines", ["Front-Gate", "Back-Gate"], ["green", "deepskyblue"])
 #      , Guide.ylabel("Derivative(Id)"), Guide.xlabel("Vg(V)")
 #      , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
 #          , major_label_font_size=18pt, minor_label_font_size=18pt
 #          )
 #      )

# draw(SVG("../../nthu-master-thesis/images/FgBg_Compare_Id.svg", 18cm, 12cm), pId)
# draw(SVG("../../nthu-master-thesis/images/FgBg_Compare_Id_dev.svg", 18cm, 12cm), pIddev)
savefig(pIddev, "FgBg_Compare_Id_dev.svg")
savefig(pId, "FgBg_Compare_Id.svg")

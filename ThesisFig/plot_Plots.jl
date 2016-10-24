
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


using Plots
using DataFrames


colorkey = [:deepskyblue :green :firebrick :olive]

# Thesis Figure: Ch3

dIdgbs_005v = readtable("./data/1030/IdVsurface_1030_2-7&2-8_PBS_Vds=0.5v.txt", separator='\t', header=true)
dIdgbs_005v[:line] = "Vds=0.5v"
dIdgbs_005v[:diffId] = diff(dIdgbs_005v[:Vsurface_3_2_], dIdgbs_005v[:Id2_8_2_2_])
dIdgbs_075v = readtable("./data/1030/IdVsurface_1030_2-7&2-8_PBS_Vds=0.75v.txt", separator='\t', header=true)
dIdgbs_075v[:line] = "Vds=0.75v"
dIdgbs_075v[:diffId] = diff(dIdgbs_075v[:Vsurface_3_2_], dIdgbs_075v[:Id2_8_2_2_])
dIdgbs_125v = readtable("./data/1030/IdVsurface_1030_2-7&2-8_PBS_Vds=1.25v.txt", separator='\t', header=true)
dIdgbs_125v[:line] = "Vds=1.25v"
dIdgbs_125v[:diffId] = diff(dIdgbs_125v[:Vsurface_3_2_], dIdgbs_125v[:Id2_8_2_2_])
dIdgbs_150v = readtable("./data/1030/IdVsurface_1030_2-7&2-8_PBS_Vds=1.5v.txt", separator='\t', header=true)
dIdgbs_150v[:line] = "Vds=1.5v"
dIdgbs_150v[:diffId] = diff(dIdgbs_150v[:Vsurface_3_2_], dIdgbs_150v[:Id2_8_2_2_])

dDisparity = DataFrame(NwA_Id = dIdgbs_075v[:Id2_8_2_2_], NwB_Id = dIdgbs_075v[:Id2_7_4_2_]
                    , NwA_diff = diff(dIdgbs_075v[:Vsurface_3_2_], dIdgbs_075v[:Id2_8_2_2_])
                    , NwB_diff = diff(dIdgbs_075v[:Vsurface_3_2_], dIdgbs_075v[:Id2_7_4_2_])
                    )

# pyplot()
plotlyjs()
# gr()
# PyPlot.svg(true)

plot()

# Id-gbs for various Vd
pIdgbs_Vd = plot([  dIdgbs_005v[:Id2_8_2_2_] dIdgbs_075v[:Id2_8_2_2_] dIdgbs_125v[:Id2_8_2_2_] dIdgbs_150v[:Id2_8_2_2_]
                 ]
                , [ dIdgbs_005v[:diffId] dIdgbs_075v[:diffId] dIdgbs_125v[:diffId] dIdgbs_150v[:diffId]
                  ]
                , xscale = :log10
                , yscale = :log10
                , xlabel = "Id(A)"
                , ylabel = "Derivative(Id)"
                # , ticks = [-6:-5]
                , xlims = ((10.0^-7.5), (10.0^-3))
                , ylims = ((10.0^-6.8), (10.0^-4))
                , linestyle = :solid
                , linecolor = colorkey
                , linewidth = 1
                , label = ["Vds=0.5v" "Vds=0.75v" "Vds=1.25v" "Vds=1.5v"]
                , marker = ([:hex :d], 5, colorkey)
                , markersize = 20
                , markerstrokewidth = 0
                , leg = :left
                , size = (800, 400)
                , fmt = :png
            )
# savefig(pIdgbs_Vd, "pIdgbs_Vd.svg")
# savefig(pIdgbs_Vd,  "pIdgbs_Vd.png")


# Id-Vg and gbs_Ib
# pIdgbs = plot([  dIdgbs_005v[:Id2_8_2_2_]]
#                 , [ dIdgbs_005v[:diffId]]
#                 , xscale = :log10
#                 , yscale = :log10
#                 , xlabel = "Id(A)"
#                 , ylabel = "Derivative(Id)"
#                 , xticks = [-7:-5]
#                 , yticks = [-6:-5]
#                 , ylims = ((10.0^-6.8), (10.0^-4.5))
#                 , legend = false
#                 , linestyle = :solid
#                 , linecolor = :deepskyblue
#                 , linewidth = 3
#             )

#
pIdVg = plot([  dIdgbs_005v[:Vsurface_3_2_]]
                , [ dIdgbs_005v[:Id2_8_2_2_]]
                , yscale = :log10
                , xlabel = "Vg(V)"
                , ylabel = "Id(A)"
                # , yticks = [-9:-5]
                , xticks = [0 : 3]
                , yticks = [-7 : -5]
                , xlims = (-0.3, 3.3)
                , ylims = ((10.0^-7.5), (10.0^-4))
                , linestyle = :solid
                , linecolor = :deepskyblue
                , linewidth = 3
                , legend = false
            )
#
pgbsVg = plot([  dIdgbs_005v[:Vsurface_3_2_]]
                , [ dIdgbs_005v[:diffId]]
                , yscale = :log10
                , xlabel = "Vg(V)"
                , ylabel = "Derivative(Id)"
                # , yticks = [-9:-5]
                , xticks = [0 : 3]
                , yticks = [-7 : -5]
                , xlims = (-0.3, 3.3)
                , ylims = ((10.0^-7.5), (10.0^-4))
                , linestyle = :solid
                , linecolor = :deepskyblue
                , linewidth = 3
                , legend = false
            )
#
# savefig(pIdgbs, "pIdgbs.svg")
# savefig(pIdVg, "pIdVg.svg")
# savefig(pgbsVg, "pgbsVg.svg")
#
############################################################

# gbs_Ib For element disparity
pDisparity = plot([dDisparity[:NwA_Id] dDisparity[:NwB_Id]
                 ]
                , [dDisparity[:NwA_diff] dDisparity[:NwB_diff]
                  ]
                , xscale = :log10
                , yscale = :log10
                , xlabel = "Id(A)"
                , ylabel = "Derivative(Id)"
                # , ticks = [-6:-5]
                , xlims = ((10.0^-7.5), (10.0^-3.5))
                , ylims = ((10.0^-6.8), (10.0^-4))
                , linestyle = :solid
                , linecolor = colorkey
                , linewidth = 1
                , label = ["Nw.2-7" "Nw.2-8"]
                , marker = ([:hex :d], 5, colorkey)
                , markersize = 20
                , markerstrokewidth = 0
                , legend = :bottom
                , size = (800, 400)
            )
# savefig(pDisparity, "pDisparity.svg")
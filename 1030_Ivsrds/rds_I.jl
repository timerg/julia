
using DataFrames
using Plots
gr()

db2 = readtable("./I_rds2_7075_100.txt", header=true, separator='\t')
p_075100_svg = plot(db2[:Id_100]
                , db2[:rds]
                , xscale = :log10
                , yscale = :log10
                , xlabel = "Id(A)"
                , ylabel = "rds"
                # # , ticks = [-6:-5]
                , xlims = ((10.0^-8), (10.0^-4))
                , ylims = ((10.0^4), (10.0^8))
                , linestyle = :solid
                , linecolor = colorant"green"
                , linewidth = 2
                # # , label = ["Nw.2-7" "Nw.2-8"]
                , legend = :none
                , marker = (:d, 10, colorant"green")
                , markerstrokewidth = 0
                , size = (600, 300)
                , fmt = :svg
            )
savefig(p_075100_svg, "rds_I_075100.svg")

dpmooRds = readtable("./pmosRds.txt", header=true, separator=' ')
dpmooRds[:rds] = 1/dpmooRds[:lx8]
dpmooRds[:current] = -1*dpmooRds[:current]
p_PmosvsNW = plot([db2[:Id_100] dpmooRds[:current][11:3:72]]
                , [db2[:rds] dpmooRds[:rds][11:3:72]]
                , xscale = :log10
                , yscale = :log10
                , xlabel = "Id(A)"
                , ylabel = "rds"
                # # , ticks = [-6:-5]
                # , xlims = ((10.0^-8), (10.0^-4))
                # , ylims = ((10.0^4), (10.0^8))
                , linestyle = :solid
                , linecolor = [colorant"green" colorant"deepskyblue"]
                , linewidth = 2
                # # , label = ["Nw.2-7" "Nw.2-8"]
                # , legend = :none
                # , marker = (:d, 10, colorant"green")
                # , markerstrokewidth = 0
                , size = (600, 300)
                , fmt = :svg
            )

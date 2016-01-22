using Gadfly
using RDatasets
using Cairo
# using Fontconfig

#### NW

a = 1:1000

function f(x)
    y = (1+0.01*x)/(1+0.001*x)
end

yy = f(a)

pr = plot(x = xx, y = yy, Geom.line, Scale.x_log10)
#
#
#
# rds2_7 = [da; db; dc; dd]
# rds2_8 = [de; df; dg; dh]
#
# # @show r2_7050_075[:,1]
# #
# # DataFrame(A = 1:10, B = v, C = rand(10))
# #
# #
# # plot(x=r2_7050_075[:,1], y=r2_7050_075[:,2], Geom.line)
#
# #### the pmos I&rds info
# fname = "rdsVScurrent.txt"
# file =  open(readdlm, fname)
# fname2 = "rdsVScurrent_nmos.txt"
# file2 =  open(readdlm, fname2)
# x = 3:133
# rdsPmos = DataFrame(Vgs = file[x, 1], rds = file[x, 2], Id = file[x, 3], name = "Pmos 20u/.4u m=3 vds=1.3", gm = file[x, 4])
# x = 2:402
# rdsNmos = DataFrame(Id = file2[x, 1], gm = file2[x, 2], rds = file2[x, 3], gmxrdsn = file2[x, 4], name = "Nmos 3u/.4u m=1 CommonGate")
#
# #### plot
#
# p2_7  = plot(rds2_7, x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
#     Theme(default_point_size = 2px))
# p2_8  = plot(rds2_8, x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
#     Theme(default_point_size = 2px))
# p_NW = plot([rds2_7; rds2_8], x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
#     Theme(default_point_size = 2px))
# p_all = plot(layer([rds2_7; rds2_8], x="Id", y="rds", color="name", Geom.point),
#                 layer(rdsPmos[(rdsPmos[:Id].>1e-8)&(rdsPmos[:Id].<1e-4),:], x="Id", y="rds", color="name", Geom.line),
#                 layer(rdsNmos[(rdsNmos[:Id].>1e-8)&(rdsNmos[:Id].<1e-4),:], x="Id", y="gmxrdsn", color="name", Geom.line),
#                  Scale.y_log10, Scale.x_log10,
#                 Theme(default_point_size = 1.5px))
#
# # draw(PNG("rds_I.png", 12cm, 6cm), p_all)
#
# # http://samuelcolvin.github.io/JuliaByExample/#Packages-and-Including-of-Files

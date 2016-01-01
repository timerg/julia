using Gadfly
# using RDatasets
using Cairo

fname = "tranient_1030_2-7&2-8_PBS_surfacebias_reloadddh2o.txt"
file =  open(readdlm, fname)
fname = "transient_1014_2-1_PBS.txt"
file2 =  open(readdlm, fname)
fname = "2_8-Vbs_Ids_gbs.csv"
file3 = readtable(fname, header=true)
tr10302_7 = DataFrame(time = file[3:412, 6], Id = file[3:412, 5], name = "2_7")
tr10302_8 = DataFrame(time = file[3:412, 2], Id = file[3:412, 1], name = "2_8")
NW2_8_vds1v_1 = DataFrame(vbs = file3[:, 1], Id = file3[:, 2], gbs = file3[:, 6], name ="2_8(1)", nameA = "Id", nameB = "gbs" )
NW2_8_vds1v_2 = DataFrame(vbs = file3[:, 1], Id = file3[:, 3], gbs = file3[:, 7], name ="2_8(2)", nameA = "Id", nameB = "gbs" )
NW2_8_vds1v_3 = DataFrame(vbs = file3[:, 1], Id = file3[:, 4], gbs = file3[:, 8], name ="2_8(3)", nameA = "Id", nameB = "gbs" )
NW2_8_vds1v_4 = DataFrame(vbs = file3[:, 1], Id = file3[:, 5], gbs = file3[:, 9], name ="2_8(4)", nameA = "Id", nameB = "gbs" )
# input signal
output_max = NW2_8_vds1v_3[:gbs] * 0.2 + NW2_8_vds1v_3[:Id]
output_min = -NW2_8_vds1v_3[:gbs] * 0.2 + NW2_8_vds1v_3[:Id]
theplot  = plot(
    layer(NW2_8_vds1v_3, x="vbs", y="Id", ymax=output_max, ymin=output_min, color="nameA", Geom.line, Geom.errorbar)
    ,layer(NW2_8_vds1v_3, x="vbs", y="gbs", color="nameB", Geom.line)
    # ,layer(NW2_8_vds1v_1, x="vbs", y=output, Geom.point)
    ,Scale.y_log10
)

trplot = plot(tr10302_8, x="time", y="Id", color="name", Theme(default_point_size = 1.5px))

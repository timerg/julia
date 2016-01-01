using Gadfly
# using RDatasets
using Cairo

fname = "NW2-1tr.csv"
file1 =  readtable(fname, header=true)
fname = "NW2-1(3).csv"
file3 = readtable(fname, header=true)
tr2_1 = DataFrame(time = file1[:, 1], Id = file1[:, 2], name = "transient")
NW2_1 = DataFrame(vbs = file3[:, 1], Id = file3[:, 2], gbs = file3[:, 3], name ="2_1")
# generate input signal dataframe
vershift = 0.2e-6
output_max = NW2_1[:gbs] * 0.05 + NW2_1[:Id] + vershift
output_min = -NW2_1[:gbs] * 0.05 + NW2_1[:Id] + vershift
x = 7
v = NW2_1[:Id][x, 1] + vershift
v_max = output_max[x, 1]
v_min = output_min[x, 1]
model = DataFrame(time = file1[:, 1], va = v, va_max = v_max, va_min = v_min)
##### plot
trplot = plot(
    layer(model, x="time", y="va", ymin="va_min", ymax="va_max", Geom.line, Geom.errorbar)
    ,layer(tr2_1, x="time", y="Id", color="name", Geom.point, Theme(default_point_size = 5px, default_color=colorant"orange"))
    ,Theme(background_color = colorant"white")
)

draw(PNG("inputrange.png", 24cm, 12cm), trplot)

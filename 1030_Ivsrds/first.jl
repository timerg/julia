using Gadfly
using RDatasets
using Cairo
# using Fontconfig

#### NW
ra = readcsv("I_rds2_7050_075.csv")
rb = readcsv("I_rds2_7075_100.csv")
rc = readcsv("I_rds2_7100_125.csv")
rd = readcsv("I_rds2_7125_150.csv")
re = readcsv("I_rds2_8050_075.csv")
rf = readcsv("I_rds2_8075_100.csv")
rg = readcsv("I_rds2_8100_125.csv")
rh = readcsv("I_rds2_8125_150.csv")

da = DataFrame(Id = abs(ra[:,1]), rds = abs(ra[:,2]), name = "r2_7050_075")
db = DataFrame(Id = abs(rb[:,1]), rds = abs(rb[:,2]), name = "r2_7075_100")
dc = DataFrame(Id = abs(rc[:,1]), rds = abs(rc[:,2]), name = "r2_7100_125")
dd = DataFrame(Id = abs(rd[:,1]), rds = abs(rd[:,2]), name = "r2_7125_150")
de = DataFrame(Id = abs(re[:,1]), rds = abs(re[:,2]), name = "r2_8050_075")
df = DataFrame(Id = abs(rf[:,1]), rds = abs(rf[:,2]), name = "r2_8075_100")
dg = DataFrame(Id = abs(rg[:,1]), rds = abs(rg[:,2]), name = "r2_8100_125")
dh = DataFrame(Id = abs(rh[:,1]), rds = abs(rh[:,2]), name = "r2_8125_150")

rds2_7 = [da; db; dc; dd]
rds2_8 = [de; df; dg; dh]

# @show r2_7050_075[:,1]
#
# DataFrame(A = 1:10, B = v, C = rand(10))
#
#
# plot(x=r2_7050_075[:,1], y=r2_7050_075[:,2], Geom.line)

#### the pmos I&rds info
fname = "rdsVScurrent.txt"
file =  open(readdlm, fname)
fname2 = "rdsVScurrent_nmos.txt"
file2 =  open(readdlm, fname2)
x = 3:133
rdsPmos = DataFrame(Vgs = file[x, 1], rds = file[x, 2], Id = file[x, 3], name = "Pmos 20u/.4u m=3 vds=1.3", gm = file[x, 4])
x = 2:402
rdsNmos = DataFrame(Id = file2[x, 1], gm = file2[x, 2], rds = file2[x, 3], gmxrdsn = file2[x, 4], name = "Nmos 3u/.4u m=1 CommonGate")

#### plot

p2_7  = plot(rds2_7, x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
    Theme(default_point_size = 2px))
p2_8  = plot(rds2_8, x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
    Theme(default_point_size = 2px))
p_NW = plot([rds2_7; rds2_8], x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
    Theme(default_point_size = 2px))
ticks = [4:8]
p_all = plot(layer(rds2_7, x="Id", y="rds", color="name",Geom.line, Theme(line_width=3pt)),
            #  layer(rds2_8, x="Id", y="rds", color="name", Geom.point),
                # layer(rdsPmos[(rdsPmos[:Id].>1e-8)&(rdsPmos[:Id].<1e-4),:], x="Id", y="rds", color="name", Geom.line),
                # layer(rdsNmos[(rdsNmos[:Id].>1e-8)&(rdsNmos[:Id].<1e-4),:], x="Id", y="gmxrdsn", color="name", Geom.line),
                 Scale.y_log10, Scale.x_log10, Guide.yticks(ticks=ticks),
                Theme(default_point_size = 1.5px, background_color=colorant"white"))

# draw(PNG("rds_I.png", 30cm, 20cm), p_all)

db2 = readtable("./I_rds2_7075_100.txt", header=true, separator='\t')

p_075100 = plot(layer(db2, x="Id_100", y="rds",Geom.line, Theme(line_width=3pt)),
            #  layer(rds2_8, x="Id", y="rds", color="name", Geom.point),
                # layer(rdsPmos[(rdsPmos[:Id].>1e-8)&(rdsPmos[:Id].<1e-4),:], x="Id", y="rds", color="name", Geom.line),
                # layer(rdsNmos[(rdsNmos[:Id].>1e-8)&(rdsNmos[:Id].<1e-4),:], x="Id", y="gmxrdsn", color="name", Geom.line),
                Guide.xlabel("ID(A)"),
                Guide.ylabel("rds"),
                 Scale.y_log10, Scale.x_log10, Guide.yticks(ticks=ticks),
                 Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                      , major_label_font_size=18pt, minor_label_font_size=18pt)
                )
draw(PNG("rds_I_075100.png", 30cm, 20cm), p_075100)



# http://samuelcolvin.github.io/JuliaByExample/#Packages-and-Including-of-Files

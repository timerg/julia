using Gadfly
using RDatasets
using Cairo
# using Fontconfig

#### NW
ra = readcsv("./NW/I_rds2_7050_075.csv")
rb = readcsv("./NW/I_rds2_7075_100.csv")
rc = readcsv("./NW/I_rds2_7100_125.csv")
rd = readcsv("./NW/I_rds2_7125_150.csv")
re = readcsv("./NW/I_rds2_8050_075.csv")
rf = readcsv("./NW/I_rds2_8075_100.csv")
rg = readcsv("./NW/I_rds2_8100_125.csv")
rh = readcsv("./NW/I_rds2_8125_150.csv")

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
fname = "rdsp.txt"
# file =  open(readdlm, fname)
file = readtable(fname, separator = ' ', header = true)
file = DataFrame(Id = file[:Id], Z = 1/file[:rdsp], name = "PmosRds")
fname2 = "gmnrdsn.txt"
file2 = readtable(fname2, separator = ' ', header = true)
file2 = DataFrame(Id = file2[:current], gmrdn = file2[:gmrdn], name = "gmrdsn")
# fname3 = "Zin.txt"
# file3 = readtable(fname3, separator = ' ', header = true)
# file3 = DataFrame(Id = file3[:id], Z = file3[:zin], name = "zin")



#
#### plot

ticks = [0:10]
p_all = plot(layer([rds2_7; rds2_8], x="Id", y="rds", color="name", Geom.point),
                layer(file[(file[:Id].>1e-8)&(file[:Id].<1e-4),:], x="Id", y="Z", color = "name", Geom.line),
                layer(file2[(file2[:Id].>1e-8)&(file2[:Id].<1e-4),:], x="Id", y="gmrdn", color="name", Geom.line),
                # layer(file3[(file3[:Id].>1e-8)&(file3[:Id].<1e-4),:], x="Id", y="Z", color="name", Geom.line),
                 Scale.y_log10, Scale.x_log10, Guide.yticks(ticks=ticks),
                Theme(default_point_size = 2px, background_color=colorant"white"))
# p_compare = plot(layer(file[(file[:Id].>1e-8)&(file[:Id].<1e-6),:], x="Id", y="Z", color = "name", Geom.line),
#                 layer(file3[(file3[:Id].>1e-8)&(file3[:Id].<1e-6),:], x="Id", y="Z", color="name", Geom.line),
#                 Theme(background_color=colorant"white"))
draw(PNG("rds_I.png", 30cm, 20cm), p_all)
#
# # http://samuelcolvin.github.io/JuliaByExample/#Packages-and-Including-of-Files

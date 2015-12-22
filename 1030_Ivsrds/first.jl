using Gadfly
using RDatasets
using Cairo
# using Fontconfig

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

p2_7  = plot(rds2_7, x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
    Theme(default_point_size = 2px))
p2_8  = plot(rds2_8, x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
    Theme(default_point_size = 2px))
p_all = plot([rds2_7; rds2_8], x="Id", y="rds", color="name", Geom.point, Scale.x_log10, Scale.y_log10,
    Theme(default_point_size = 2px))

draw(PNG("rds_I.png", 12cm, 6cm), p_all)

# http://samuelcolvin.github.io/JuliaByExample/#Packages-and-Including-of-Files

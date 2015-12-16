using Gadfly
# using RDatasets

r2_7050_075 = readcsv("I_rds2_7050_075.csv")
r2_7075_100 = readcsv("I_rds2_7075_100.csv")
r2_7100_125 = readcsv("I_rds2_7100_125.csv")
r2_7125_150 = readcsv("I_rds2_7125_150.csv")
r2_8050_075 = readcsv("I_rds2_8050_075.csv")
r2_8075_100 = readcsv("I_rds2_8075_100.csv")
r2_8100_125 = readcsv("I_rds2_8100_125.csv")
r2_8125_150 = readcsv("I_rds2_8125_150.csv")


@show r2_7050_075[:,1]



plot(x=r2_7050_075[:,1], y=r2_7050_075[:,2])



# http://samuelcolvin.github.io/JuliaByExample/#Packages-and-Including-of-Files

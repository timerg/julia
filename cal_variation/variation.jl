using Gadfly
using RDatasets
using Cairo

fname = "tranient_1030_2-7&2-8_PBS_surfacebias_reloadddh2o.txt"
file =  open(readdlm, fname)
fname = "transient_1014_2-1_PBS.txt"
file2 =  open(readdlm, fname)
tr10302_7 = DataFrame(time = file[3:412, 6], Id = file[3:412, 5], name = "2_7")
tr10302_8 = DataFrame(time = file[3:412, 2], Id = file[3:412, 1], name = "2_8")


using RDatasets
# using CurveFit
# ENV["PLOTS_USE_ATOM_PLOTPANE"] = "false"
using Plots
pyplot()
dcvma = readtable("./data/0828/CVM_a.txt", separator='\t', header=true)

p = plot(sin, rand(10), fmt = :png, show = true)
p1 = plot(dcvma[:Vg], dcvma[:Vc], fmt = :png, show = true)

# savefig("test")
png(p1, "test")

using DataFrames; gadfly()
iris = dataset("datasets", "iris")

scatter(iris, :SepalLength, :SepalWidth, group=:Species,
        title = "My awesome plot", xlabel = "Length", ylabel = "Width",
        m=(0.5, [:+ :h :star7], 12), bg=RGB(.2,.2,.2))

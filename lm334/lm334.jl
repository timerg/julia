using Gadfly
using Cairo
using RDatasets
# using CurveFit

function diff(xs, ys)
    l = length(xs)
    derv = DataArray{Float64, 1}(zeros(l))
    for i in collect(2 : (l-1))
        derv[i] = (ys[i + 1] - ys[i - 1])/(xs[i + 1] - xs[i - 1])
    end
    derv[1] = (ys[3] - ys[1])/(xs[3] - xs[1])
    derv[l] = (ys[l] - ys[l-2])/(xs[l] - xs[l-2])
    # derv[1] = NaN
    # derv[l] = NaN
    return derv
end

dlm334 = readtable("./lm334.txt", separator='\t', header=true)

dlm334[:res] = diff(dlm334[:I], dlm334[:V])
plm334_imp = plot(dlm334[dlm334[:res] .< 1e10, :], x=:V, y=:res, Geom.line
                , Guide.ylabel("Impedance")
                , Guide.xlabel("Vb")
                , Scale.y_log10
                , Theme(default_color=colorant"green", line_width=3pt, background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                     , major_label_font_size=18pt, minor_label_font_size=18pt)
                 )


using Gadfly
using RDatasets
using Cairo


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

function init(a)
    l = length(a)
    a = a[2 : l]
    return(a :: Tuple)
end

function operate_row_(f :: Function, l, a0 :: DataArray, a1 :: DataArray, as :: Tuple)
    for i = 1 : l
        a0[i] = f(a0[i], a1[i])
    end
    if as == ()
        return a0
    else
        return operate_row_(f, l, a0, as[1], init(as))
    end
end

function operate_row(f :: Function, a1, a...)
    l = length(a1)
    a0 = @data(zeros(l))
    for i = 1 : l
        a0[i] = a1[i]
    end
    return operate_row_(f, l, a0, a[1], init(a))
end

function mean_onRow(d :: DataFrame, as :: Array = [])
    l = length(d)
    if as == []
        as = 1 : l
    end
    s = size(d, 1)
    mean = zeros(s)
    for i = as
        for j = 1 : s
            mean[j] = mean[j] + d[i][j]
        end
    end
    mean = mean / length(as)
    return mean
end

input = readtable("./data/1117/vopa0_LoffRon_vz1.1.txt", header=true, separator='\t')
rename!(input, (:out_2_1_ => :LoffRon, :Vin_1_1_ => :Vin))
input[:LoffRoff] = readtable("./data/1117/vopa0_LoffRoff_vz1.1.txt", header=true, separator='\t')[2]
input[:LonRon] = readtable("./data/1117/vopa0_LonRon_vz1.1.txt", header=true, separator='\t')[2]
input[:LonRoff] = readtable("./data/1117/vopa0_LonRoff_vz1.1.txt", header=true, separator='\t')[2]

input_diff = DataFrame(Vin = input[:Vin])
input_diff[:LoffRoff] = diff(input[:Vin], input[:LoffRoff])
input_diff[:LoffRon]  = diff(input[:Vin], input[:LoffRon])
input_diff[:LonRoff]  = diff(input[:Vin], input[:LonRoff])
input_diff[:LonRon]   = diff(input[:Vin], input[:LonRon])

plot = Gadfly.plot(layer(input, x="Vin", y="LoffRoff", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
     , layer(input, x="Vin", y="LoffRon", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
     , layer(input, x="Vin", y="LonRoff", Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
     , layer(input, x="Vin", y="LonRon", Geom.line, Theme(default_color=colorant"mediumorchid", line_width=3pt))
     , Guide.manual_color_key("Line", ["LoffRoff", "LoffRon", "LonRoff", "LonRon"], ["deepskyblue", "green", "maroon", "mediumorchid"])
     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
     , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
      )


plot_diff = Gadfly.plot(layer(input_diff, x="Vin", y="LoffRoff", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3pt))
     , layer(input_diff, x="Vin", y="LoffRon", Geom.line, Theme(default_color=colorant"green", line_width=3pt))
     , layer(input_diff, x="Vin", y="LonRoff", Geom.line, Theme(default_color=colorant"maroon", line_width=3pt))
     , layer(input_diff, x="Vin", y="LonRon", Geom.line, Theme(default_color=colorant"mediumorchid", line_width=3pt))
     , Guide.manual_color_key("Line", ["LoffRoff", "LoffRon", "LonRoff", "LonRon"], ["deepskyblue", "green", "maroon", "mediumorchid"])
     , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
     , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
      )












#
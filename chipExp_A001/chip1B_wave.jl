using Gadfly
using Cairo
using RDatasets
using CurveFit



d_100fold = readtable("./data/1209/scope_0.txt", separator='\t', header=true)
rename!(d_100fold, :x_axis, :time)

plot_d = plot(
     layer(d_100fold, x=:time, y=:x1, Geom.line, Theme(default_color=colorant"green"))
   , layer(d_100fold, x=:time, y=:x2, Geom.line)
   , Guide.xlabel("time(s)")
   , Guide.ylabel("V")
   , Guide.manual_color_key("Line", ["vopa", "vopi"], ["deepskyblue", "green"])
   , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
       , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
   )

draw(PNG("Fig/Chip1/wave_1B_100fold_VopiandVopa.png", 24cm, 20cm), plot_d)

# Average

function Average(a::DataArray, n::Int64)
    l = length(a)
    out = convert(DataArray, zeros(round(Int, l/n)))
    i = 0
    start = 0
    stop = 0
    while i < n
        start = round(Int, l * i/n + 1)
        stop = round(Int, l * (i+1)/n)
        out = out + a[start:stop]
        i = i + 1
    end
    out = out ./ n
    return out
end
# x2_av = Average(d_100fold[:x1], 5)
x1_av = Average(d_100fold[:x1], 5)
plot_av = plot(y = x1_av, Geom.line)


# LP

function LP(a::DataArray, x::Int64)
    l = length(a)
    i = 2
    out = copy(a)
    while i <= x
        out[i:l]  = out[i:l] + a[1:(l - i + 1)]
        i = i + 1
    end
    out = out[(2 + x):l] ./ x
    return out
end

x2_LP = LP(d_100fold[:x2], 5)
x1_LP = LP(x1_av, 2)
# d_100fold_LP = DataFrame(x2 = x2_LP, x1 = x1_LP)
plot_LP_vopi = plot(y = x1_LP, Geom.line
                , Guide.xlabel("time(ms)")
                , Guide.ylabel("Vopi(V)")
                , Theme(default_color=colorant"green", background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )
draw(PNG("Fig/Chip1/wave_1B_100fold_Vopi.png", 24cm, 20cm), plot_LP_vopi)
plot_LP_vopa = plot(y = x2_LP, Geom.line, Theme(default_color=colorant"deepskyblue")
                , Guide.xlabel("time(s)")
                , Guide.ylabel("Vopa(V)")
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )
draw(PNG("Fig/Chip1/wave_1B_100fold_Vopa.png", 24cm, 20cm), plot_LP_vopa)




d_10fold = readtable("./data/1209/scope_2.txt", separator='\t', header=true)
rename!(d_10fold, :x_axis, :time)

plot_d = plot(
     layer(d_10fold, x=:time, y=:x1, Geom.line, Theme(default_color=colorant"green"))
   , layer(d_10fold, x=:time, y=:x2, Geom.line)
   , Guide.xlabel("time(s)")
   , Guide.ylabel("V")
   , Guide.manual_color_key("Line", ["vopa", "vopi"], ["deepskyblue", "green"])
   , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
       , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
   )
draw(PNG("Fig/Chip1/wave_1B_10fold_VopiandVopa.png", 24cm, 20cm), plot_d)

x1_av = Average(d_10fold[:x1], 5)

x2_LP = LP(d_10fold[:x2], 5)
x1_LP = LP(x1_av, 2)

plot_LP_vopa = plot(y = x2_LP, Geom.line, Theme(default_color=colorant"deepskyblue")
                , Guide.xlabel("time(s)")
                , Guide.ylabel("Vopa(V)")
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )
draw(PNG("Fig/Chip1/wave_1B_10fold_Vopa.png", 24cm, 20cm), plot_LP_vopa)



# 1222
d_square1 = readtable("./data/1220_osilloscope/square_1.txt", separator='\t', header=true)
p_square1 = plot(layer(d_square1, x="x_axis", y=:"x1", Geom.line, Theme(default_color=colorant"green"))
                ,layer(d_square1, x="x_axis", y=:"x2", Geom.line)
                , Guide.xlabel("time(s)")
                , Guide.ylabel("Vopa(V)")
                , Guide.title(string("1st Stage Output:", maximum(d_square1[:x1]), "v -", minimum(d_square1[:x1]), "v | ", "2nd Stage Output:", maximum(d_square1[:x2]), "v - ", minimum(d_square1[:x2]), "v"))
                , Guide.manual_color_key("Line", ["1st Stage Output", "2nd Stage Output"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )
d_square2 = readtable("./data/1220_osilloscope/square_2.txt", separator='\t', header=true)
p_square2 = plot(layer(d_square2, x="x_axis", y=:"x1", Geom.line, Theme(default_color=colorant"green"))
                ,layer(d_square2, x="x_axis", y=:"x2", Geom.line)
                , Guide.yticks(ticks=collect(0:0.1:2.5))
                , Guide.xlabel("time(s)")
                , Guide.ylabel("Vout(V)")
                , Guide.title(string("1st Stage Output:", maximum(d_square2[:x1]), "v - ", minimum(d_square2[:x1]), "v | ", "2nd Stage Output:", maximum(d_square2[:x2]), "v - ", minimum(d_square2[:x2]), "v"))
                , Guide.manual_color_key("Line", ["1st Stage Output", "2nd Stage Output"], ["green", "deepskyblue"])
                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                )
draw(PNG("Fig/Chip1/100foldProved_trianglewave.png", 28cm, 20cm), p_square2)




# OP Gain
d_OPgainC1 = readtable("./data/1226/OPGainofChip1.txt", separator='\t', header=true)
d_OPgainC4 = readtable("./data/1226/OPGainofChip4.txt", separator='\t', header=true)
d_OPgainC4[:x_axis] = d_OPgainC4[:x_axis] + 0.18
p_OPgain = plot(
                          layer(d_OPgainC4[250:750, :], x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"yellowgreen"))
                        , layer(d_OPgainC1, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"darkblue"))
                        , Guide.title("Input = 1mV, 1Hz \n The Gain is less than 2k(66dB)")
                        , Guide.xlabel("time(s)")
                        , Guide.ylabel("Vout(V)")
                        , Guide.manual_color_key("", ["Chip1B", "Chip4B"], ["darkblue", "yellowgreen"])
                        , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                            , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
                    )
draw(PNG("Fig/Chip1/Problem_OPGain.png", 28cm, 20cm), p_OPgain)
# http://mirlab.org/jang/books/audioSignalProcessing/filterApplication_chinese.asp?title=11-1%20Filter%20Applications%20(%C2o%AAi%BE%B9%C0%B3%A5%CE)
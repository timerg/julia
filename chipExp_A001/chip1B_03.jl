using Gadfly
using Cairo
using RDatasets
using Suppressor


function mydiff(xs, ys)
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

function notInclude(x, a)
    l = length(a)
    for i = 1 : l
        if x == a[i]
            return false
        end
    end
    return true
end

function handleTicks(x, i...)
    if notInclude(x, i)
        @sprintf("1e%i", x)
    else
        @sprintf("%0.1e", 10.0^x)
    end
end

# # d_pHTest_1 = readtable("./data/03/pHTest_fail.txt", separator='\t', header=true) #This one fail due to the first rise is not Flat
# # p_pHTest_1 = plot(layer(d_pHTest_1, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green"))
# #                 , Guide.xlabel("time(s)")
# #                 , Guide.ylabel("Vout(V)")
# #                 , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
# #                     , major_label_font_size=30pt, minor_label_font_size=30pt, line_width=1pt)
# #             )
#
# d_pHTest_2 = readtable("./data/03/pHTest_succ.txt", separator='\t', header=true)
# p_pHTest_2 = plot(d_pHTest_2, x=:x_axis, y=:x1, Geom.line
#                 , Coord.cartesian(ymin=0.8, ymax=2)
#                 , Guide.xlabel("time(s)")
#                 , Guide.ylabel("Vout(V)")
#                 , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
#                     , major_label_font_size=30pt, minor_label_font_size=30pt, line_width=5pt, default_color=colorant"green")
#             )
#
# draw(PNG("Fig/March/PHTest.png", 30cm, 15cm), p_pHTest_2)
#
#
d_noise = readtable("./data/03/noise_3.txt", separator='\t', header=true)
d_noise[:innoise] = (sqrt(d_noise[:Vopa]) ./ (8.91e6) )
# d_noise_log = DataFrame(F = [1:100], N = 10.0.^(log10(d_noise[:innoise]) - log10([1:100])))
d_noise[:noise_log] = 10.0.^(log10(d_noise[:innoise][1]) - log10(d_noise[:Frequency]))
p_noise = plot(d_noise, x=:Frequency, y=:innoise, Geom.line

                , Coord.cartesian(ymin=-11, ymax=-8.5)
                , Guide.xticks(ticks=[1, log10(60), 2, 3])
                , Scale.x_log10(labels=x -> @sprintf("%i", round(10.0^(x))) )
                , Scale.y_log10
                , Guide.xlabel("Frequency(Hz)")
                , Guide.ylabel("Input referred noise(A)")

                , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
                    , major_label_font_size=30pt, minor_label_font_size=30pt, line_width=5pt, default_color=colorant"black")
            )

draw(PNG("Fig/March/Noise.png", 30cm, 15cm), p_noise)
#
#
d_amp10x = readtable("./data/03/amp10x.txt", separator='\t', header=true)
d_amp10x[:x_axis] = d_amp10x[:x_axis] * 10
p_amp10x = plot(layer(d_amp10x[325:825, :], x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"black", line_width=5pt))
                , layer(d_amp10x[325:825, :], x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"silver", line_width=5pt))
                , Coord.cartesian(xmin=-3, xmax=2.5)
                , Guide.xlabel("time(s)")
                , Guide.ylabel("")
                , Guide.manual_color_key("", ["Vin(V)", "Vout(V)"], ["silver", "black"])
                , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
                    , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
            )   # gain = 9.2

draw(PNG("Fig/March/SecondStageAmp10x.png", 30cm, 15cm), p_amp10x)
#
d_sub_xin = readtable("./data/03/sub_xin.txt", separator='\t', header=true)
# p_sub_xin = plot(layer(d_sub_xin, x=:x1, y=:x2, Geom.line, Theme(default_color=colorant"black", line_width=5pt))
#                 # , layer(d_sub_xin, x=:x1, y=:x1, Geom.line, Theme(default_color=colorant"silver", line_width=2pt))
#                 , Coord.cartesian(xmin=0.3, xmax=1.5)
#                 , Guide.xticks(ticks=[1:0.5:1.5, 0.43, 1.3, 0.8])
#                 , Guide.xlabel("Vin(V)")
#                 , Guide.ylabel("Vout(V)")
#                 # , Guide.manual_color_key("", ["Vout(expected)", "Vout(measured)"], ["silver", "black"])
#                 , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
#                     , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
#             )
#
d_sub_xin[:out_ideal] = d_sub_xin[:x1] + (1.1 - 0.8)
p_sub_xin_scope = plot(layer(d_sub_xin, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"silver", line_width=5pt))
                , layer(d_sub_xin, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"black", line_width=5pt), order=1)
                # , layer(x=d_sub_xin[:x_axis], y=(d_sub_xin[:x2] - d_sub_xin[:x1]), Geom.line)
                # , Coord.cartesian(xmin=0.3, xmax=1.5)
                # , Guide.xticks(ticks=[0.5:0.5:1.5, 0.62, 1.32, 0.8])
                , Guide.xlabel("time(s)")
                , Guide.ylabel("")
                , Guide.manual_color_key("", ["Vin(V)", "Vout(V)"], ["silver", "black"])
                , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
                    , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
            )
# draw(PNG("Fig/March/SubtractorXin.png", 21cm, 21cm), p_sub_xin)
draw(PNG("Fig/March/SubtractorXin_scope.png", 35cm, 15cm), p_sub_xin_scope)
#
d_sub_zin = readtable("./data/03/subtractor_zin.txt", separator='\t', header=true)
p_sub_zin = plot(layer(d_sub_zin, x=:x1, y=:x2, Geom.line, Theme(default_color=colorant"black", line_width=5pt))
                # , layer(d_sub_zin, x=:x1, y=:x1, Geom.line, Theme(default_color=colorant"silver", line_width=5pt))
                , Coord.cartesian(xmin=0.6, xmax=1.5)
                , Guide.xticks(ticks=[1, 1.47, 1.2, 0.62, 0.8])
                , Guide.xlabel("Vz(V)")
                , Guide.ylabel("Vout(V)")
                , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
                    , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
            )
#
p_sub_zin_scope = plot(layer(d_sub_zin, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"black", line_width=5pt))
                        , layer(d_sub_zin, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"silver", line_width=5pt))
                        # , layer(x=d_sub_zin[:x_axis], y=d_sub_zin[:x2] - d_sub_zin[:x1], Geom.line)
                        , Coord.cartesian(xmin=0.3, xmax=1.5)
                        , Guide.xticks(ticks=[0.5:0.5:1.5, 0.62, 1.32, 0.8])
                        , Guide.yticks(ticks=[0:1:3])
                        , Guide.xlabel("time(s)")
                        , Guide.ylabel("(V)")
                        , Guide.manual_color_key("", ["Vz input (V)", "Vout(V)"], ["black", "silver"])
                        , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
                            , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
                    )
#
#
#
# d_sub_zoffset_1x = readtable("./data/03/zoffset_1x.txt", separator='\t', header=true)
# d_sub_zoffset_10x = readtable("./data/03/zoffset_10x.txt", separator='\t', header=true)
#
# p_sub_zoffset_1x = plot(layer(d_sub_zoffset_1x, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"black", line_width=5pt))
#                         , layer(d_sub_zoffset_1x, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"silver", line_width=5pt))
#                         # , Coord.cartesian(xmin=0.3, xmax=1.5)
#                         # , Guide.xticks(ticks=[0.5:0.5:1.5, 0.62, 1.32, 0.8])
#                         # , Guide.yticks(ticks=[0:1:3, 0:0.05:0.5])
#                         , Guide.manual_color_key("", ["Vz", "Output of 2nd Stage circuit"], ["black", "silver"])
#                         , Guide.xlabel("time(s)")
#                         , Guide.ylabel("(V)")
#                         , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
#                             , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
# )
#
# d_sub_zoffset_1x_n = readtable("./data/03/zoffset_1x_noise.txt", separator='\t', header=true)
# p_sub_zoffset_1x_n = plot(layer(d_sub_zoffset_1x_n, x=:x_axis, y=:x2, Geom.line, order=1, Theme(default_color=colorant"silver", line_width=1pt))
#                         , layer(d_sub_zoffset_1x_n, x=:x_axis, y=:x1, Geom.line, order=2, Theme(default_color=colorant"black", line_width=1pt))
#                         # , Coord.cartesian(xmin=0.3, xmax=1.5)
#                         # , Guide.xticks(ticks=[0.5:0.5:1.5, 0.62, 1.32, 0.8])
#                         # , Guide.yticks(ticks=[0:1:3, 0:0.05:0.5])
#                         , Guide.manual_color_key("", ["Vz", "Output of 2nd Stage circuit"], ["black", "silver"])
#                         , Guide.xlabel("time(s)")
#                         , Guide.ylabel("(V)")
#                         , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=1pt
#                             , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
# )
#
#
# p_sub_zoffset_10x = plot(layer(d_sub_zoffset_10x, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"black", line_width=5pt))
#                         , layer(d_sub_zoffset_10x, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"silver", line_width=5pt))
#                         # , Coord.cartesian(xmin=0.3, xmax=1.5)
#                         # , Guide.xticks(ticks=[0.5:0.5:1.5, 0.62, 1.32, 0.8])
#                         # , Guide.yticks(ticks=[0:1:3, 0:0.05:0.5])
#                         , Guide.manual_color_key("", ["Vz", "Output of 2nd Stage circuit"], ["black", "silver"])
#                         , Guide.xlabel("time(s)")
#                         , Guide.ylabel("(V)")
#                         , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
#                             , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
#                             )
# )
#
# # draw(PNG("Fig/March/SubtractorZoffset_10x.png", 35cm, 15cm), p_sub_zoffset_10x)
# # draw(PNG("Fig/March/SubtractorZoffset_1x.png", 35cm, 15cm), p_sub_zoffset_1x)
# # draw(PNG("Fig/March/SubtractorZoffset_1x_noise.png", 40cm, 20cm), p_sub_zoffset_1x_n)
# draw(PNG("Fig/March/SubtractorZoffset.png", 21cm, 21cm), p_sub_zin)
# draw(PNG("Fig/March/SubtractorZoffset_scope.png", 35cm, 15cm), p_sub_zin_scope)
d_sub_noise = readtable("./data/03/sub_noise.txt", separator='\t', header=true)
p_sub_noise = plot(d_sub_noise, x=:x_axis, y=:x2, Geom.line
                , Guide.xlabel("time(s)")
                , Guide.ylabel("Vout(V)")
                , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
                    , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
                )
draw(PNG("Fig/March/Subtractor_noise.png", 30cm, 15cm), p_sub_noise)
# Noise avg
noise_avg = plot(d_sub_noise[d_sub_noise[:x2] .< 1.1, :], x=:x_axis, y=:x2, Geom.line
                , Guide.xlabel("")
                , Guide.ylabel("")
                # , Guide.yticks(ticks=nothing)
                , Guide.xticks(ticks=nothing)
                , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
                    , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green")
                )

#
#
#
# d_bw_10x = readtable("./data/03/Bandwidth_10x.txt", separator='\t', header=true)
# d_bw_10x[:Gain] = 20 * log10(d_bw_10x[:Out] / 0.2 * 0.98e6)
# p_bw_10x = plot(layer(d_bw_10x, x=:Frequency, y=:Gain, Geom.line, Theme(default_color=colorant"black", line_width=5pt))
#                         , Coord.cartesian(xmin=1)
#                         , Guide.xlabel("Frequency(Hz)")
#                         , Guide.ylabel("Gain")
#                         , Scale.x_log10(labels=x -> handleTicks(x, 4.47))
#                         , Scale.y_continuous(labels=x -> @sprintf("%d dB", x))
#                         , Guide.yticks(ticks=[119, 116, 115, 105, 110])
#                         , Guide.xticks(ticks=[1:1:5, 4.47])
#                         , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
#                             , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
#                             )
# )
#
# d_bw_100x = readtable("./data/03/Bandwidth_100x.txt", separator='\t', header=true)
# d_bw_100x[:Gain] = 20 * log10(d_bw_100x[:Out] / 0.2 * 0.98e6)
# p_bw_100x = plot(layer(d_bw_100x, x=:Frequency, y=:Gain, Geom.line, Theme(default_color=colorant"black", line_width=5pt))
#                         , Coord.cartesian(xmin=1, xmax=5)
#                         , Guide.xlabel("Frequency(Hz)")
#                         , Guide.ylabel("Gain")
#                         , Scale.x_log10(labels=x -> handleTicks(x, log10(7500)))
#                         , Scale.y_continuous(labels=x -> @sprintf("%0.1f dB", x))
#                         , Guide.yticks(ticks=[138.96, 134, 135, 137, 138, 135.96])
#                         , Guide.xticks(ticks=[1:1:3, log10(7500)])
#                         , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt
#                             , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
#                             )
# )
#
# draw(PNG("Fig/March/Bw_10x.png", 35cm, 15cm), p_bw_10x)
# draw(PNG("Fig/March/Bw_100x.png", 35cm, 15cm), p_bw_100x)
#
#
# d_trimp_neg = readtable("./data/03/Iin+.txt", separator='\t', header=true)
# d_trimp_neg[:Iin_2_1_] = d_trimp_neg[:Iin_2_1_] * (-1)
# d_trimp_neg[:fit] = d_trimp_neg[:Iin_2_1_] * 103000 + 0.78
# d_trimp_neg[:fit][45:51] = d_trimp_neg[:Vout][45:51]
# d_trimp_neg[:Derivative] = mydiff(d_trimp_neg[:Iin_2_1_], d_trimp_neg[:fit])
# # p_trimp_neg = plot(layer(d_trimp_neg, x=:Iin_2_1_, y=:Vout, Geom.line)
# #                     # , layer(d_trimp_neg, x=:Iin_2_1_, y=:fit, Geom.line, Theme(default_color=colorant"blue"))
# #                     , Coord.cartesian(xmax=-4.3)
# #                     , Guide.xticks(ticks=[-7, -6, log10(2e-5)])
# #                     , Guide.xlabel("Iin(A)")
# #                     , Guide.ylabel("Vout(V)")
# #                     , Scale.x_log10(labels=x -> handleTicks(x, log10(2e-5)))
# #                     , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt, line_width=3pt
# #                         , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
# #                      )
# #                  )
#
# d_trimp_neg_stack = stack(d_trimp_neg, [:Vout,:Derivative])
# p_trimp_neg = plot(d_trimp_neg_stack, ygroup="variable", x=:Iin_2_1_, y="value"
#                  , Geom.subplot_grid(Geom.line, free_y_axis=true
#                      , Guide.xticks(ticks=[-7, -6, log10(1.5e-5)])
#                      , Scale.x_log10(labels=x -> handleTicks(x, log10(1.5e-5)))
#                      )
#
#                  , Guide.ylabel("")
#                  , Guide.xlabel("Iin(A)")
#                  , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt, line_width=5pt
#                      , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
#                   )
#                  )
#
# d_trimp_pos = readtable("./data/03/Iin-.txt", separator='\t', header=true)
# d_trimp_pos[:Iin_2_1_] = d_trimp_pos[:Iin_2_1_]
# d_trimp_pos[:fit] = - d_trimp_pos[:Iin_2_1_] * 103000 + 0.78
# d_trimp_pos[:fit][23:34] = d_trimp_pos[:Vout][23:34]
# d_trimp_pos[:Derivative] = mydiff(d_trimp_pos[:Iin_2_1_], d_trimp_pos[:fit]) * (-1)
# # p_trimp_pos = plot(layer(d_trimp_pos, x=:Iin_2_1_, y=:Vout, Geom.line)
# #                 #  , layer(d_trimp_pos, x=:Iin_2_1_, y=:fit, Geom.line, Theme(default_color=colorant"blue"))
# #                  , Coord.cartesian(xmax=-4.6)
# #                  , Guide.xticks(ticks=[-8, -7, -6, log10(7.9e-6)])
# #                  , Guide.xlabel("Iin(A)")
# #                  , Guide.ylabel("Vout(V)")
# #                  , Scale.x_log10(labels=x -> handleTicks(x, log10(7.9e-6)))
# #                  , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt, line_width=1pt
# #                      , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
# #                   )
# #               )
# #
# # p_trimp_pos_dev = plot(layer(d_trimp_pos, x=:Iin_2_1_, y=:Derivative, Geom.line)
# #                  , Coord.cartesian(xmax=-4.6)
# #                  , Guide.xticks(ticks=[-8, -7, -6, log10(7.9e-6)])
# #                  , Guide.yticks(ticks=[0, 5e4, 1.05e5, 1.5e5])
# #                  , Guide.xlabel("Iin(A)")
# #                  , Guide.ylabel("Vout(V)")
# #                  , Scale.x_log10(labels=x -> handleTicks(x, log10(7.9e-6)))
# #                  , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt, line_width=3pt
# #                      , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
# #                   )
# #               )
#
# d_trimp_pos_stack = stack(d_trimp_pos, [:Vout,:Derivative])
# p_trimp_pos = plot(d_trimp_pos_stack, ygroup="variable", x=:Iin_2_1_, y="value"
#                     , Geom.subplot_grid(Geom.line, free_y_axis=true
#                         , Guide.xticks(ticks=[-8, -7, -6, log10(5.3e-6)])
#                         , Scale.x_log10(labels=x -> handleTicks(x, log10(5.3e-6)))
#                         )
#                     , Guide.ylabel("")
#                     , Guide.xlabel("Iin(A)")
#                     , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt, line_width=5pt
#                         , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
#                      )
#                     )
#
#
# draw(PNG("Fig/March/Trimp_I+.png", 32cm, 20cm), p_trimp_pos)
# draw(PNG("Fig/March/Trimp_I-.png", 32cm, 20cm), p_trimp_neg)
#

d_sin_0600na = readtable("data/03/sin_500m_600na.csv", separator=',', header=true)
d_sin_1000na = readtable("data/03/sin_500m_1ua.csv", separator=',', header=true)
d_sin_1390na = readtable("data/03/sin_500m_1390na.csv", separator=',', header=true)
d_sin_1500na = readtable("data/03/sin_500m_1500na.csv", separator=',', header=true)
d_sin_1500na[:x_axis] = d_sin_1500na[:x_axis] - 0.00024

p_sin_1p8u = plot(
            # layer(d_sin_0600na, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"#c6c4c4"))
            # , layer(d_sin_1390na, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"#717171"))
            layer(d_sin_1500na, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"black" ))  # 2.6u
            , Coord.cartesian(xmin=-0.01)
            , Guide.xticks(ticks=[-0.01:0.005:0])
            , Guide.yticks(ticks=[0.5:0.2:2 ])
            , Guide.xlabel("times(s)")
            , Guide.ylabel("Vout(V)")
            , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt, line_width=3pt
             , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
                  )

)

p_sin_1u = plot(
            layer(d_sin_0600na, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"black"))
            , Coord.cartesian(xmin=-0.01)
            , Guide.xticks(ticks=[-0.01:0.005:0])
            , Guide.yticks(ticks=[0.8:0.1:1.5 ])
            , Guide.xlabel("times(s)")
            , Guide.ylabel("Vout(V)")
            , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt, line_width=3pt
             , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"green"
                  )

) #1u
#
# draw(PNG("Fig/March/Sin_1p8u.png", 30cm, 15cm), p_sin_1p8u)
# draw(PNG("Fig/March/Sin_1u.png", 30cm, 15cm), p_sin_1u)


# Ibias

d_Ibias = readtable("data/03/Ibias.txt", separator='\t', header=true)

p_Ibias = plot(d_Ibias, x=:R_m, y=:I_bias, Geom.line
            , Scale.x_log10
            , Scale.y_log10
            , Guide.xlabel("R_external(Ω)")
            , Guide.ylabel("Ibias(A)")
            , Theme(key_title_font_size=30pt, key_label_font_size=30pt, grid_line_width=3pt, line_width=5pt
                , major_label_font_size=30pt, minor_label_font_size=30pt, default_color=colorant"black")
            )

draw(PNG("Fig/March/Ibias.png", 21cm, 21cm), p_Ibias)







#### 0421
#
# dnw = readtable("data/0421/nw3-4.txt", separator='\t', header=true)
# dnw[:gm] = mydiff(dnw[:Voltage_1], dnw[:Current_1])
#
# pnw = plot(dnw, x=:Current_1, y=:gm, Geom.line
#             , Guide.xticks(ticks=[-6:0.1:-5, -9:1:-5])
#             , Guide.yticks(ticks=[-8:1:-5, -5.3])
#             , Scale.x_log10
#             , Scale.y_log10
#             )
#
#
# d_12p6nA = readtable("data/0421/0421_10.csv", separator=',', header=true)
# d_12p6nA = d_12p6nA[501:1000, :]
# d_31p5nA = readtable("data/0421/0421_3.csv", separator=',', header=true)
# d_31p5nA = d_31p5nA[501:1000, :]
# d_63p1nA = readtable("data/0421/0421_1.csv", separator=',', header=true)
# d_63p1nA = d_63p1nA[501:1000, :]
# d_94p6nA = readtable("data/0421/0421_6.csv", separator=',', header=true)
# d_94p6nA = d_94p6nA[501:1000, :]
# d_126pnA = readtable("data/0421/0421_8.csv", separator=',', header=true)
# d_126pnA = d_126pnA[501:1000, :]
# d_158pnA = readtable("data/0421/0421_11.csv", separator=',', header=true)
# d_158pnA = d_158pnA[501:1000, :]
# d_189pnA = readtable("data/0421/0421_13.csv", separator=',', header=true)
# d_189pnA = d_189pnA[501:1000, :]
# d_221pnA = readtable("data/0421/0421_16.csv", separator=',', header=true)
# d_221pnA = d_221pnA[501:1000, :]
#
# d_130puA = readtable("data/0421/0421_26.csv", separator=',', header=true)
# d_130puA = d_130puA[301:800, :]
# d_155puA = readtable("data/0421/0421_23.csv", separator=',', header=true)
# d_155puA = d_155puA[101:600, :]
# d_180puA = readtable("data/0421/0421_22.csv", separator=',', header=true)
# d_180puA = d_180puA[301:800, :]
# d_205puA = readtable("data/0421/0421_19.csv", separator=',', header=true)
# d_205puA = d_205puA[1:500, :]
# d_230puA = readtable("data/0421/0421_17.csv", separator=',', header=true)
# d_230puA = d_230puA[501:1000, :]
#
# d_12p6nA_lo = sum(d_12p6nA[1:90, 2]) / 90
# d_12p6nA_hi = sum(d_12p6nA[150:250, 2]) / 101
# dv_12p6nA = d_12p6nA_hi - d_12p6nA_lo
# p_12p6nA = plot(d_12p6nA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_12p6nA[:x2][1] - 0.1, ymax = d_12p6nA[:x2][1] + 1)
#                 # , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_12p6nA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_31p5nA_lo = sum(d_31p5nA[301:390, 2]) / 90
# d_31p5nA_hi = sum(d_31p5nA[100:200, 2])/ 101
# dv_31p5nA = d_31p5nA_hi - d_31p5nA_lo
# p_31p5nA = plot(d_31p5nA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_31p5nA[:x2][1] - 0.1, ymax = d_31p5nA[:x2][1] + 1)
#                 , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_31p5nA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_63p1nA_lo = sum(d_63p1nA[401:490, 2]) / 90
# d_63p1nA_hi = sum(d_63p1nA[110:210, 2])/ 101
# dv_63p1nA = d_63p1nA_hi - d_63p1nA_lo
# p_63p1nA = plot(d_63p1nA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_63p1nA[:x2][1] - 0.1, ymax = d_63p1nA[:x2][1] + 1)
#                 , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_63p1nA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_94p6nA_lo = sum(d_94p6nA[401:490, 2]) / 90
# d_94p6nA_hi = sum(d_94p6nA[110:210, 2])/ 101
# dv_94p6nA = d_94p6nA_hi - d_94p6nA_lo
# p_94p6nA = plot(d_94p6nA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_94p6nA[:x2][1] - 0.1, ymax = d_94p6nA[:x2][1] + 1)
#                 , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_94p6nA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_126pnA_lo = sum(d_126pnA[401:490, 2]) / 90
# d_126pnA_hi = sum(d_126pnA[110:210, 2])/ 101
# dv_126pnA = d_126pnA_hi - d_126pnA_lo
# p_126pnA = plot(d_126pnA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_126pnA[:x2][1] - 0.1, ymax = d_126pnA[:x2][1] + 1)
#                 # , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_126pnA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_158pnA_hi = sum(d_158pnA[301:390, 2]) / 90
# d_158pnA_lo = sum(d_158pnA[110:210, 2])/ 101
# dv_158pnA = d_158pnA_hi - d_158pnA_lo
# p_158pnA = plot(d_158pnA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_158pnA[:x2][1] - 0.1, ymax = d_158pnA[:x2][1] + 1)
#                 , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_158pnA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_189pnA_lo = sum(d_189pnA[301:390, 2]) / 90
# d_189pnA_hi = sum(d_189pnA[110:210, 2])/ 101
# dv_189pnA = d_189pnA_hi - d_189pnA_lo
# p_189pnA = plot(d_189pnA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_189pnA[:x2][1] - 0.1, ymax = d_189pnA[:x2][1] + 1)
#                 , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_189pnA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_221pnA_lo = sum(d_221pnA[401:490, 2]) / 90
# d_221pnA_hi = sum(d_221pnA[110:210, 2])/ 101
# dv_221pnA = d_221pnA_hi - d_221pnA_lo
# p_221pnA = plot(d_221pnA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_221pnA[:x2][1] - 0.1, ymax = d_221pnA[:x2][1] + 1)
#                 , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_221pnA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_130puA_lo = sum(d_130puA[401:490, 2]) / 90
# d_130puA_hi = sum(d_130puA[160:260, 2])/ 101
# dv_130puA = d_130puA_hi - d_130puA_lo
# p_130puA = plot(d_130puA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_130puA[:x2][1] - 0.1, ymax = d_130puA[:x2][1] + 1)
#                 # , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_130puA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_155puA_lo = sum(d_155puA[1:90, 2]) / 90
# d_155puA_hi = sum(d_155puA[250:350, 2])/ 101
# dv_155puA = d_155puA_hi - d_155puA_lo
# p_155puA = plot(d_155puA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_155puA[:x2][1] - 0.1, ymax = d_155puA[:x2][1] + 1)
#                 # , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_155puA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_180puA_lo = sum(d_180puA[1:90, 2]) / 90
# d_180puA_hi = sum(d_180puA[150:250, 2])/ 101
# dv_180puA = d_180puA_hi - d_180puA_lo
# p_180puA = plot(d_180puA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_180puA[:x2][1] - 0.1, ymax = d_180puA[:x2][1] + 1)
#                 # , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_180puA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_205puA_lo = sum(d_205puA[1:90, 2]) / 90
# d_205puA_hi = sum(d_205puA[200:300, 2])/ 101
# dv_205puA = d_205puA_hi - d_205puA_lo
# p_205puA = plot(d_205puA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_205puA[:x2][1] - 0.1, ymax = d_205puA[:x2][1] + 1)
#                 # , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_205puA, "V"))
#                 , Guide.ylabel("")
#                 )
#
# d_230puA_lo = sum(d_230puA[1:90, 2]) / 90
# d_230puA_hi = sum(d_230puA[220:320, 2])/ 101
# dv_230puA = d_230puA_hi - d_230puA_lo
# p_230puA = plot(d_230puA, y=:x2, Geom.line
#                 , Coord.cartesian(ymin = d_230puA[:x2][1] - 0.1, ymax = d_230puA[:x2][1] + 1)
#                 # , Guide.yticks(label=false)
#                 , Guide.title(string("△V = ", dv_230puA, "V"))
#                 , Guide.ylabel("")
#                 )
#
#
# # amp rate:
# # fronted stage: 107k
# # 10x: 9.82
# # 100x: 92.2
#
RTIA = 107000
tenFold = 9.82
hundredFold = 92.2
tenToHundred = hundredFold / tenFold
#
# Vout = [dv_12p6nA, dv_31p5nA, dv_63p1nA, dv_94p6nA, dv_126pnA, dv_158pnA, dv_189pnA * tenToHundred, dv_221pnA * tenToHundred]
# Vin = [0.02, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35]
# dItoVout = DataFrame(
#                       Vout = Vout
#                     # , Iin = [12.6e-9, 31.5e-9, 63.1e-9, 94.6e-9, 126e-9, 158e-9, 189e-9, 221e-9]
#                     , Vin = Vin
#                     , Iin = map(string, map(x -> round(x, 9), Vout / RTIA / hundredFold))
#                     , fit = Vin * RTIA * hundredFold * 3.7e-7
#                     )
# # dItoVout[:fit] = dItoVout[:Iin] * 6000000
#
# p_ItoVout = plot(layer(dItoVout, x=:Vin, y=:fit, Geom.line, order=1)
#                 ,layer(dItoVout, x=:Vin, y=:Vout, label = :Iin, Geom.line, Geom.point, Geom.label(position=:right)
#                             , Theme(default_color=colorant"green", line_width=3pt, default_point_size=5pt))
#                 , Guide.xticks(ticks=dItoVout[:Vin])
#                 , Guide.ylabel("Vout")
#                 , Theme(key_title_font_size=20pt, key_label_font_size=20pt, grid_line_width=2pt
#                  , major_label_font_size=20pt, minor_label_font_size=12pt)
#                 )
# draw(PNG("Fig/March/VinToVout.png", 21cm, 15cm), p_ItoVout)
#
# dItoVout_fs = DataFrame(
#                       Iin = [1.3e-6, 1.55e-6, 1.8e-6, 2.05e-6, 2.3e-6]
#                     , Vout = [dv_130puA, dv_155puA, dv_180puA, dv_205puA, dv_230puA]
#                     )
# dItoVout_fs[:fit] = dItoVout_fs[:Vout] / 107000
#
# p_ItoVout_fs = plot(layer(dItoVout_fs, x=:Iin, y=:Vout, Geom.line, Geom.point)
#     # ,layer(dItoVout_fs, x=:Iin, y=:fit, Geom.line)
#         , Guide.xticks(ticks = [dItoVout_fs[:Iin]]))
#
#
# abs(dItoVout[:fit] - dItoVout[:Vin]) ./ dItoVout[:Vin]

#

# 0425

d_0425_20mV = readtable("data/0425/0425_1.csv", separator=',', header=true)
d_0425_20mV = d_0425_20mV[1:501, :]
d_0425_20mV_lo = sum(d_0425_20mV[1:100, 2]) / 100
d_0425_20mV_hi = sum(d_0425_20mV[251:350, 2]) / 100
# d_0425_20mV_lo = maximum(d_0425_20mV[1:100, 2])
# d_0425_20mV_hi = maximum(d_0425_20mV[251:350, 2])
dv_0425_20mV = d_0425_20mV_hi - d_0425_20mV_lo
p_0425_20mV = plot(d_0425_20mV, y=:x1, Geom.line
                # , Coord.cartesian(ymin = d_0425_20mV[:x1][1] - 0.1, ymax = d_0425_20mV[:x1][1] + 1)
                , Coord.cartesian(xmax=500, xmin=100)
                # , Guide.yticks(label=false)
                , Guide.ylabel("Vout(V)")
                , Guide.xlabel("Time(s)")
                # , Guide.title(string("△V = ", dv_0425_20mV, "V"))
                , Theme(background_color=colorant"white", key_title_font_size=30pt, key_label_font_size=30pt
                   , major_label_font_size=30pt, minor_label_font_size=30pt, line_width=2pt, default_color=colorant"black")
                )
draw(PNG("Fig/March/VinToVout_scope_0425_20mV.png", 30cm, 15cm), p_0425_20mV)

d_0425_50mV = readtable("data/0425/0425_2.csv", separator=',', header=true)
d_0425_50mV = d_0425_50mV[101:600, :]
d_0425_50mV_lo = sum(d_0425_50mV[1:100, 2]) / 100
d_0425_50mV_hi = sum(d_0425_50mV[251:350, 2]) / 100
# d_0425_50mV_lo = maximum(d_0425_50mV[1:100, 2])
# d_0425_50mV_hi = maximum(d_0425_50mV[251:350, 2])
dv_0425_50mV = d_0425_50mV_hi - d_0425_50mV_lo
p_0425_50mV = plot(d_0425_50mV, y=:x1, Geom.line
                , Coord.cartesian(ymin = d_0425_50mV[:x1][1] - 0.1, ymax = d_0425_50mV[:x1][1] + 1)
                # , Guide.yticks(label=false)
                , Guide.title(string("△V = ", dv_0425_50mV, "V"))
                , Guide.ylabel("")
                )

d_0425_100mV = readtable("data/0425/0425_3.csv", separator=',', header=true)
d_0425_100mV = d_0425_100mV[501:1000, :]
d_0425_100mV_lo = sum(d_0425_100mV[301:400, 2]) / 100
d_0425_100mV_hi = sum(d_0425_100mV[121:220, 2]) / 100
# d_0425_100mV_lo = maximum(d_0425_100mV[301:400, 2])
# d_0425_100mV_hi = maximum(d_0425_100mV[121:220, 2])
dv_0425_100mV = d_0425_100mV_hi - d_0425_100mV_lo
p_0425_100mV = plot(d_0425_100mV, y=:x1, Geom.line
                , Coord.cartesian(ymin = d_0425_100mV[:x1][1] - 0.1, ymax = d_0425_100mV[:x1][1] + 1)
                , Guide.yticks(label=false)
                , Guide.title(string("△V = ", dv_0425_100mV, "V"))
                , Guide.ylabel("")
                )

d_0425_150mV = readtable("data/0425/0425_4.csv", separator=',', header=true)
d_0425_150mV = d_0425_150mV[501:1000, :]
d_0425_150mV_lo = sum(d_0425_150mV[401:500, 2]) / 100
d_0425_150mV_hi = sum(d_0425_150mV[151:250, 2]) / 100
dv_0425_150mV = maximum(d_0425_150mV_hi) - maximum(d_0425_150mV_lo)
p_0425_150mV = plot(d_0425_150mV, y=:x1, Geom.line
                # , Coord.cartesian(ymin = d_0425_150mV[:x1][1] - 0.1, ymax = d_0425_150mV[:x1][1] + 1)
                # , Guide.yticks(label=false)
                # , Guide.title(string("△V = ", dv_0425_150mV, "V"))
                # , Guide.ylabel("")
                , Guide.ylabel("Vout(V)")
                , Guide.xlabel("Time(s)")
                , Theme(background_color=colorant"white", key_title_font_size=30pt, key_label_font_size=30pt
                   , major_label_font_size=30pt, minor_label_font_size=30pt, line_width=2pt, default_color=colorant"black")
                )
draw(PNG("Fig/March/VinToVout_scope_0425_150mV.png", 30cm, 15cm), p_0425_150mV)
#
dv_0425_200mV = 0.377
dv_0425_300mV = 0.6
dv_0425_400mV = 0.9
dv_0425_500mV = 1.1
# dv_0425_700mV = 1.526  X saturate
#

dItoVout_0425 = DataFrame(Vin=[0.02, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5], Vout=[dv_0425_20mV, dv_0425_50mV, dv_0425_100mV, dv_0425_150mV, dv_0425_200mV, dv_0425_300mV ,dv_0425_400mV, dv_0425_500mV])
writetable("data/0425/0425_VinToVout.txt", dItoVout_0425, separator = '\t', header=true)
dItoVout_0425[:Iin] = map(string, round(dItoVout_0425[:Vout] / hundredFold / RTIA, 10))
p_ItoVout_0425 = plot(layer(dItoVout_0425, x=:Vin, y=:Vout
                        , Geom.point
                        , label=:Iin, Geom.label(position=:right)
                        , Geom.smooth(method=:lm,smoothing=1.0)
                        )
                    , Guide.ylabel("△Vout")
                    , Guide.xlabel("△VG")
                    , Coord.cartesian(xmin = 0, xmax = 0.6)
                    # ,layer(dItoVout_fs, x=:Iin, y=:fit, Geom.line)
                    , Guide.xticks(ticks = dItoVout_0425[:Vin])
                    , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                       , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
        )


draw(PNG("Fig/March/VinToVout_0425.png", 30cm, 15cm), p_ItoVout_0425)


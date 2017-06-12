using Gadfly
using Cairo
using RDatasets
using Suppressor
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


### 0314
# d_pH_4 = readtable("./data/03/pHTest/ph_04.csv", separator=',', header=true)
# d_pH_5 = readtable("./data/03/pHTest/ph_05.csv", separator=',', header=true)
# d_pH_6 = readtable("./data/03/pHTest/ph_06_2.csv", separator=',', header=true)
#
# p_pH_4 = plot(layer(d_pH_4, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green"))
#             , layer(d_pH_4, x=:x_axis, y=:x2, Geom.line)
#             , Guide.xlabel("Time(s)")
#             , Guide.ylabel("Vout(V)")
#             , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#             )
#
# p_pH_5 = plot(layer(d_pH_5, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green"))
#             , layer(d_pH_5, x=:x_axis, y=:x2, Geom.line)
#             , Guide.xlabel("Time(s)")
#             , Guide.ylabel("Vout(V)")
#             , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#             )
#
# p_pH_6 = plot(layer(d_pH_6, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green"))
#             , layer(d_pH_6, x=:x_axis, y=:x2, Geom.line)
#             , Guide.xlabel("Time(s)")
#             , Guide.ylabel("Vout(V)")
#             , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#             )


### 0312

# d_pH_a = readtable("./data/03/0322/phtest_0322_.csv", separator=',', header=true)
# d_pH_b = readtable("./data/03/0322/phtest_0322_1.csv", separator=',', header=true)
# d_pH_c = readtable("./data/03/0322/phtest_0322_2.csv", separator=',', header=true)
# d_pH_d = readtable("./data/03/0322/phtest_0322_3.csv", separator=',', header=true)
# d_pH_e = readtable("./data/03/0322/phtest_0322_4.csv", separator=',', header=true)
# d_pH_f = readtable("./data/03/0322/phtest_0322_5.csv", separator=',', header=true)
# d_pH_g = readtable("./data/03/0322/phtest_0322_6.csv", separator=',', header=true)
# d_pH_h = readtable("./data/03/0322/phtest_0322_7.csv", separator=',', header=true)
# d_pH_i = readtable("./data/03/0322/phtest_0322_8.csv", separator=',', header=true)
#
# dnw = vcat(d_pH_b[:x1], d_pH_c[:x1], d_pH_d[:x1], d_pH_f[:x1], d_pH_g[:x1], d_pH_h[:x1])
# p_pH = plot(y=dnw, Geom.line, Theme(default_color=colorant"green")
#             , Guide.xlabel("Time(s)")
#             , Guide.ylabel("Vout(V)")
#             # , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#             #     , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#             )
# p_pH_5to4 = plot(d_pH_i, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green")
#             , Guide.xlabel("Time(s)")
#             , Guide.ylabel("Vout(V)")
#             # , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#             #     , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#             )
#
# # Drift
#
# d_drift_ddH2O = readtable("./data/03/0322/nw1-6_Tr_ddh2o.txt", separator='\t', header=true)
# d_drift_pH5 = readtable("./data/03/0322/nw1-6_Tr_ph5.txt", separator='\t', header=true)
# d_drift_pH4 = readtable("./data/03/0322/nw1-6_Tr_ph4.txt", separator='\t', header=true)
#
# p_drift = plot(layer(d_drift_pH4[1:400, :], x=:Time, y=:Current, Geom.line, Theme(default_color=colorant"green"))
#              , layer(d_drift_pH5[1:400, :], x=:Time, y=:Current, Geom.line, Theme(default_color=colorant"black"))
#              , layer(x = d_drift_pH4[:Time][1:400], y=d_drift_ddH2O[:Current][1:400], Geom.line, Theme(default_color=colorant"maroon"))
#              , Guide.xlabel("Time(s)")
#              , Guide.ylabel("ID(A)")
#              , Guide.manual_color_key("", ["pH4", "pH5", "ddH2O"], ["green", "black", "maroon"])
#              , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                  , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#                 )
#
#
# d_drift_pH4_Ig = readtable("./data/03/0322/nw1-6_Tr_ph4_Ig.txt", separator='\t', header=true)
# p_drift_Ig = plot(
#                   layer(d_drift_pH4_Ig, x=:Time, y=:Ig, Geom.line),
#                 layer(d_drift_pH4_Ig, x=:Time, y=:Current, Geom.line)
#                 )
#
# p_nw1_6_beforIg = readtable("./data/03/0322/nw1-6.txt", separator='\t', header=true)
# p_nw1_6_afterIg = readtable("./data/03/0322/nw1-6_AfterIgMeas.txt", separator='\t', header=true)
#
# p_IdVg = plot(layer(p_nw1_6_beforIg, x=:Voltage, y=:Current, Geom.line)
#             , layer(p_nw1_6_afterIg, x=:Voltage, y=:Current, Geom.line)
#             )
#
# ### 0323
# dnw_2_6 = readtable("./data/03/0323/nw2-6.txt", separator='\t', header=true)
# dnw_2_6[:gm] = diff(dnw_2_6[:Voltage], dnw_2_6[:Current])
#
# pIdgm_2_6 = plot(dnw_2_6[4:21, :], x=:Current, y=:gm, Geom.line
#                 , Guide.yticks(ticks = [-8:1:-4, log10(2e-6)])
#                 , Guide.xticks(ticks = [-10:1:-4, log10(3e-7)])
#                 , Scale.x_log10()
#                 , Scale.y_log10()
#                 )
#
#
# d_pHTest_gm5u_pH6 = readtable("./data/03/0323/ph_.csv", separator=',', header=true)
# d_pHTest_gm5u_pH5 = readtable("./data/03/0323/ph_1.csv", separator=',', header=true)
# d_pHTest_gm5u_pH4 = readtable("./data/03/0323/ph_2.csv", separator=',', header=true)
# d_pH_gm5u = DataFrame(Time = d_pHTest_gm5u_pH6[:x_axis], pH6 = d_pHTest_gm5u_pH6[:x2], pH5 = d_pHTest_gm5u_pH5[:x2], pH4 = d_pHTest_gm5u_pH4[:x2])
# d_pH_gm5u = stack(d_pH_gm5u, [:pH6, :pH5, :pH4])
# p_pH_gm5u = plot(d_pH_gm5u, ygroup="variable", x="Time", y="value", Geom.subplot_grid(
#                     Geom.line
#                     , Coord.cartesian(xmax=5)
#                     )
#                 , Guide.ylabel("Vout(V)")
#                 , Guide.xlabel("Time(s)")
#                 , Theme(background_color=colorant"white", default_color=colorant"black", key_title_font_size=18pt, key_label_font_size=18pt
#                 , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#                 )

# p_pH_gm5u = plot(layer(d_pHTest_gm5u_pH4, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"green"))
#                , layer(d_pHTest_gm5u_pH5, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"black"))
#                , layer(d_pHTest_gm5u_pH6, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"maroon"))
#                , Guide.manual_color_key("", ["pH4", "pH5", "ddH2O"], ["green", "black", "maroon"])
#                , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
#                    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
#                 )

# draw(PNG("Fig/March/pH_Test_gm5u.png", 32cm, 20cm), p_pH_gm5u)
#
#
# d_pHTest_gm1u_A = readtable("./data/03/0323/ph_gm1u_.csv", separator=',', header=true)
# d_pHTest_gm1u_B = readtable("./data/03/0323/ph_gm1u_1.csv", separator=',', header=true)
# d_pHTest_gm1u_C = readtable("./data/03/0323/ph_gm1u_2.csv", separator=',', header=true)
# d_pHTest_gm1u_D = readtable("./data/03/0323/ph_gm1u_3.csv", separator=',', header=true)
# d_pHTest_gm1u_E = readtable("./data/03/0323/ph_gm1u_4.csv", separator=',', header=true)
# d_pHTest_gm1u_F = readtable("./data/03/0323/ph_gm1u_5.csv", separator=',', header=true)
#
# p_pH_gm1u = plot(d_pHTest_gm1u_E, x=:x_axis, y=:x2, Geom.line)
#
#
# d_pHTest_gm5u_min_A = readtable("./data/03/0323/ph_min_.csv", separator=',', header=true)
# d_pHTest_gm5u_min_pH6p3 = readtable("./data/03/0323/ph_min_1.csv", separator=',', header=true)
# d_pHTest_gm5u_min_pH6 = readtable("./data/03/0323/ph_min_2.csv", separator=',', header=true)
#
# p_pHTest_gm5u_min_A = plot(d_pHTest_gm5u_min_A[1:780, :], x=:x_axis, y=:x2, Geom.line) # Bad
# p_pHTest_gm5u_min = plot(layer(d_pHTest_gm5u_min_pH6p3, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"green"))
#                            , layer(d_pHTest_gm5u_min_pH6, x=:x_axis, y=:x2, Geom.line, Theme(default_color=colorant"maroon"))
#                            , Guide.manual_color_key("", ["pH7 → pH6.5", "pH6.5 → pH6"], ["green", "maroon"])
#                            , Guide.yticks(ticks=[2.2:0.02:2.3])
#                            , Guide.ylabel("Vout(V)")
#                            , Guide.xlabel("Time(s)")
#                         #    , Theme(background_color=colorant"white", default_color=colorant"black", key_title_font_size=18pt, key_label_font_size=18pt
#                         #    , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
#                         )
#
# draw(PNG("Fig/March/pH_Test_gm5u_minor.png", 32cm, 20cm), p_pHTest_gm5u_min)

# 0425
d_0425_pH6To5a = readtable("./data/0425/0425_ph_1.csv", separator=',', header=true)
d_0425_pH5To4a = readtable("./data/0425/0425_ph_2.csv", separator=',', header=true)
d_0425_pH5To6 = readtable("./data/0425/0425_ph_3.csv", separator=',', header=true)
d_0425_pH6To5b = readtable("./data/0425/0425_ph_4.csv", separator=',', header=true)
d_0425_pH5To4b = readtable("./data/0425/0425_ph_5.csv", separator=',', header=true)
d_0425_pH6To7a = readtable("./data/0425/0425_ph_6.csv", separator=',', header=true)
d_0425_pH5To4c = readtable("./data/0425/0425_ph_7.csv", separator=',', header=true)
d_0425_pH6To5c = readtable("./data/0425/0425_ph_8.csv", separator=',', header=true)

d_0425_pH4to5d = readtable("./data/0425/0425_ph_9.csv", separator=',', header=true)
d_0425_pH5to6dx = readtable("./data/0425/0425_ph_10.csv", separator=',', header=true)
d_0425_pH5to6d = readtable("./data/0425/0425_ph_11.csv", separator=',', header=true)
d_0425_pH6to7d = readtable("./data/0425/0425_ph_12.csv", separator=',', header=true)

d_0425pH = plot(
                # layer(d_0425_pH6To5a, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH5To4a, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH5To6a, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH6To5b, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH5To4b, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH6To7a, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH5To4c, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH6To5c, x=:x_axis, y=:x1, Geom.line)
                layer(d_0425_pH4to5d, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH5to6dx, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH5to6d, x=:x_axis, y=:x1, Geom.line)
                # layer(d_0425_pH6to7d, x=:x_axis, y=:x1, Geom.line)
                , Coord.cartesian(ymin=1.2, ymax=1.5)
                )


# 0427

d_0427_pH5To4a = readtable("./data/0427/0427_ph_1.csv", separator=',', header=true)
d_0427_pH6To5a = readtable("./data/0427/0427_ph_2.csv", separator=',', header=true)
d_0427_pH6To5a_con = readtable("./data/0427/0427_ph_3.csv", separator=',', header=true)
d_0427_pH6To5a_con[:x_axis] = d_0427_pH6To5a_con[:x_axis] + 20
d_0427_pH6To5a = vcat(d_0427_pH6To5a, d_0427_pH6To5a_con)
d_0427_pH6To5a = d_0427_pH6To5a[201:1200, :]
d_0427_pH6To5b = readtable("./data/0427/0427_ph_4.csv", separator=',', header=true)
d_0427_pH7To6a = readtable("./data/0427/0427_ph_5.csv", separator=',', header=true)
d_0427_pH7To6b = readtable("./data/0427/0427_ph_6.csv", separator=',', header=true)

p_0427pH_test = plot(
                layer(d_0427_pH5To4a, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"maroon")),
                layer(d_0427_pH6To5a, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"orange")),
                layer(d_0427_pH6To5b, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"green")),
                layer(d_0427_pH7To6a, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"deepskyblue")),
                layer(d_0427_pH7To6b, x=:x_axis, y=:x1, Geom.line, Theme(default_color=colorant"purple"))
                , Coord.cartesian(ymin=1.2, ymax=1.7)
                )

d_0427pH = DataFrame(time= d_0427_pH6To5a[:x_axis]  #[1:800]
                    , pH7topH6=d_0427_pH7To6b[:x1]  #[1:800]
                    , pH6topH5=d_0427_pH6To5a[:x1]  #[1:800]
                    , pH5topH4=d_0427_pH5To4a[:x1]  #[1:800]
                    )
d_long_0427pH = stack(d_0427pH, [:pH5topH4, :pH6topH5, :pH7topH6])

p_0427pH = plot(d_long_0427pH, xgroup=:variable, x=:time, y=:value
                , Geom.subplot_grid(
                    Geom.line
                    , Coord.cartesian(ymin=1.25, ymax=1.6)
                    )
                , Guide.xlabel("Time(s)")
                , Guide.ylabel("Vout(V)")
               , Theme(background_color=colorant"white", key_title_font_size=18pt, key_label_font_size=18pt
                   , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=2pt)
                )


draw(PNG("Fig/March/pH_Test_0425.png", 32cm, 20cm), p_0427pH)





1 + 1






#
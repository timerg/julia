using Gadfly
using Cairo
using RDatasets
using CurveFit

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


### 0413
d_ddH2O = readtable("./data/0413/nw3-8_ddh2o_IdIs.txt", separator='\t', header=true)

d_pH_a = readtable("./data/0413/nw3-8_pH1st.txt", separator='\t', header=true)
d_pH_b = readtable("./data/0413/nw3-8_pH1st_cont.txt", separator='\t', header=true)
d_pH_c = readtable("./data/0413/nw3-8_pH1st_contss.txt", separator='\t', header=true)
d_pH = DataFrame(Time=d_pH_a[:Time], A=d_pH_a[:ID], B=d_pH_b[:ID], C=d_pH_c[:ID])
d_pH = stack(d_pH, [:A, :B, :C])
p_ddH2O = plot(d_ddH2O, x=:Time, y=:ID, Geom.line)
p_pH = plot(d_pH, xgroup="variable", x="Time", y="value"
            , Geom.subplot_grid(
                Geom.line
                )
            , Guide.ylabel("ID(A)")
            , Guide.xlabel("Time(s)")
            , Theme(background_color=colorant"white", default_color=colorant"black", key_title_font_size=18pt, key_label_font_size=18pt
                , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
            )


p_compare_H2OvspH = plot(layer(d_ddH2O, x=:Time, y=:ID, Geom.line, Theme(default_color=colorant"green"))
    ,layer(d_pH_a[1:301, :], x=:Time, y=:ID, Geom.line, Theme(default_color=colorant"maroon"))
    , Guide.manual_color_key("", ["pH", "ddH2O"], ["maroon", "green"])
    , Guide.ylabel("ID(A)")
    , Guide.xlabel("Time(s)")
    , Theme(background_color=colorant"white", default_color=colorant"black", key_title_font_size=18pt, key_label_font_size=18pt
        , major_label_font_size=18pt, minor_label_font_size=18pt, line_width=1pt)
       )

draw(PNG("Fig/March/pHDeBug/compare_H2OvspH.png", 32cm, 20cm), p_compare_H2OvspH)
draw(PNG("Fig/March/pHDeBug/pH_longTime.png", 32cm, 20cm), p_pH)



















#
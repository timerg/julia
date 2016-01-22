p = 10.0^-12
f = 10.0^-15
n = 10.0^-9
u = 10.0^-6

function RC(c1, c2, f1, f2)
       c = (f2 * c2 - f1 * c1)/(f1 - f2)
       r = (1/f1-1/f2)/(c1-c2)/2/3.1415926
       w = 1/r/c
       return [c, r, w]
   end
function zdc(gm, gds)
    return (1 / (gds+gm))
end

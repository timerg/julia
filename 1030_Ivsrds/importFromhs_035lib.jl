# import data From hspice_035lib_current&size pmos data
# in order to merge the plot with rds fo NW by measure to give a comparison
# hope to know how to design the stack mos on NW

using Gadfly
using RDatasets
using Cairo

#### File Open
fname = "rdsVScurrent.txt"

x = 0
# file =  open(fname ,"r") do f
#     for line in eachline(f)
#         print(line)        # print will ignore "\n" and compose autimatically
#     end
# end

###### the best
file =  open(readdlm, fname)        #http://docs.julialang.org/en/release-0.4/stdlib/io-network/?highlight=readdlm

####






#### References
#  About Arrays: http://docs.julialang.org/en/release-0.4/manual/arrays/
# https://en.wikibooks.org/wiki/Introducing_Julia/Types

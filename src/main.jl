###########
#Run this after all the files are scraped. (getdata.jl)

include("mergefiles.jl")
# This will output dfsingle and dftidy

#have to work with dfsingle
include("utilities.jl")
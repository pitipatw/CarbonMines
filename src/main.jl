###########
#Run this after all the files are scraped. (getdata.jl)
# include("getdata.jl")

include("mergefiles.jl") # This will output dfsingle and dftidy
#have to work with dfsingle
include("utilities.jl")


#should get 138400 x 328
df = joindata() # a placeholder (don't mess with this!)
dftidy = deepcopy(df) #mess with this instead!

println("There are ", size(df)[1], " data points in the dataframe")

#define functions for identifying types of each column
union_types(x::Union) = (x.a, union_types(x.b)...)
union_types(x::Type) = (x,)

colnames = names(df)
keep_columns = ones(Bool, length(colnames))
singletype_columns = zeros(Bool,length(colnames))
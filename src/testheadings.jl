#tidy up files into dataframes
using DataFrames #JSONTables, CSV
using JSON
# using Makie
 

global total_data = Vector{Any}()
total_pages = 1468 #result should have the size of 1467xx
pages = 1:total_pages
filepath = joinpath(@__DIR__)
for page in pages
    spg = "0"^(4-length(string(page)))*string(page)
    filename = "/rawdata/pg" * spg* ".json"
    vec1 = Vector{Any}()
    open(filepath*filename, "r") do f
        txt = JSON.read(f,String)  # file information to string
        vec1=JSON.parse(txt)  # parse and transform data
    end
    total_data = vcat(total_data,vec1)
end

df = DataFrame(total_data)
println(size(df))
filename = "/ECS_page_all.json"
open(filepath*filename, "w") do f
    JSON.print(f, df)
end


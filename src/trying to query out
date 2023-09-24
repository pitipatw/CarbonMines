using JLD2
using DataFrames
using PlotlyJS
using Makie, GLMakie
using kjlMakie
using ColorSchemes
using GeoMakie

include("main.jl")
include("gwp_fcprime_analysis.jl")

df_check = DataFrame(CSV.File("df_ready2.csv"))

lb = 40
ub = 45
query = lb .<= df_check[!,"fc_prime_MPa"] .&& df_check[!,"fc_prime_MPa"] .<=ub
df_check[!,"check"] = query
#CLF equation .
function clfgwp(fc_prime_MPa)
    return 0.0022*fc_prime_MPa+0.07
end

lowgwp = df_check[query,"gwp_values"] .< 0.08
highgwp = df_check[query,"gwp_values"] .> 0.3
df_query = df_check[query,:]
f1 = Figure( resolution = (1280,720))
ax1 = f1[1,1] = GeoAxis(f1,
    # title
    title = 
    "lat lon",
    titlegap = 36, titlesize = 24,
    # x-axis
    # xgridvisible = false,
    xgridcolor = :lightgray, xgridwidth = 2,
    xlabel = "long" , xlabelsize = 28,
    xticklabelsize = 24, xticks = LinearTicks(8),
    # y-axis
    # ygridvisible = false,30
    ygridcolor = :lightgray, ygridwidth = 2,
    ylabel = "lat",
    ylabelsize = 24, #ytickformat = "{:d}",
    yticklabelsize = 24, yticks = LinearTicks(7),

    coastlines = true,

    limits = (-180, -5,0,90)
)

not_query = @. !query
a = maximum(df_check[query, "gwp_values"])
a = 0.5
scatter!(ax1, df_check[not_query,"long"], df_check[not_query, "lat"], color = :grey, markersize = 10)
scatter!(ax1, df_query[highgwp, "long"],df_query[highgwp,"lat"], colormap = ColorSchemes.magma.colors , color = :green, markersize = 50)
scatter!(ax1, df_query[lowgwp, "long"],df_query[lowgwp,"lat"], colormap = ColorSchemes.magma.colors , color = :red, markersize = 50)

df_query[lowgwp, "id"]
df_query[highgwp, "id"]



#check category, 
#check name? 


# df_check[query,"fc_prime_MPa"]
# df_check[query,"fc_prime_units"]
# id_wanted = df_check[query,"id"]

# #from original dataset, data those with these id. 
# begin
# data = zeros(Bool,size(df,1))
# for i =1:(size(df,1))
#     if df[i,"id"] ∈ id_wanted
#         data[i] = true
#     end
# end
# println(sum(data))
# end
# #data id 

# df_query = df[data,:]

# # CSV.write("df_query.csv",df_query)
# # for i in eachindex(names(df)))
# #     #if type of column is dict, get the name as the suffix

# #     if typeof(df_query[!,i]) == Dict{String,Float64}
# #         name = string(names(df)[i])
# #         CSV.write("df_query_$name.csv",df_query[!,i])
# #     end




# #Experimant
# using PlotlyJS, DataFrames, CSV, Dates
# function linescatter1()
#     trace1 = scatter(;x=1:4, y=[10, 15, 13, 17], mode="markers")
#     trace2 = scatter(;x=2:5, y=[16, 5, 11, 9], mode="lines")
#     trace3 = scatter(;x=1:4, y=[12, 9, 15, 12], mode="lines+markers")
#     plot([trace1, trace2, trace3])
# end
# linescatter1()





# #load the file,
# df_ready = DataFrame(CSV.File("df_ready2.csv"))

# fc′ = df_ready[!,"fc_prime_MPa"]
# gwp = df_ready[!,"gwp_values"]
# id = df_ready[!,"id"]

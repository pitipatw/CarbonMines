# df1 = df[!, multi_types]

# #finding dicts -> flatten them
# isdict = zeros(Bool, size(multi_types))
# for i in eachindex(multi_types)
#     name = multi_types[i]

#     #get the types of the column
#     types = collect(union_types(eltype(dftidy[!,name])))
#     # println(types)

#     if (Nothing in types)  & (size(types)[1] == 1)
#         println("*",name)

#         # println("Column $i is a vector of nothing")
#         keep_columns1[i] = false
#         #THIS PART IS DONE
#     else 
#         # println(name)
#     end
# # [] and null
#     if Dict{String, Any} in types
#         println("Column $name is a vector of Dict{String,Any}")
#         i0 = name 
#         k = keys(dftidy[!,i0][1])
#         for j in eachindex(dftidy[!,i0])
#             if dftidy[j,i0] === nothing
#                 # println("null at $j")
#                 dftidy[j,i0] = Dict()
#             end
#         end
#     elseif Vector{Any} in types
        
#         # println(name)
#         # println("   Column $i is a vector")
#         # println(types)
        
#     else
#         println()
#     end
# end


    # println(types)
    # println(name)




# for i in names(df)
#     if df[!,i] isa Vector
#         for j in df[!,i]
#             if j isa Vector
#                 println("Column $i is a vector of vector{Any}")
#             end
            
#         end
#     end
# end

# #create a new empty dataframe df_mod 


# limit = 100
# small_columns = []
# for i in names(df) 
#     if typeof(df[!,i]) != Float64 || typeof(df[!,i]) != Int64
#         println(i)
#         println(typeof(df[!,i]))
#         # println(sum(df[!,i].!= nothing))
#         if sum(df[!,i].!= nothing) <=limit
#             if i ∉ small_columns 
#                 push!(small_columns,i)
#             end
#         end
#     end
# end

# dummy = size(small_columns)[1]
# println("Number of small columns (less than $limit): $dummy")

# list_of_names = names(df)
# sort!(list_of_names)

# #go through every single elements of df, 
# # check the type of each vector, to replace nothing with "" or 0.0 or 0
# function replace_nothing!(df)
# end


# for i in names(df)
#     dummy = df[!,i][1]
#     if dummy isa Dict
#     elseif dummy isa Vector
#         for j in df[!,i]
#             for k in j
#                 if typeof(k) == Float64
#                     df[!,i] = replace(df[!,i], nothing => 0.0)
#                 elseif typeof(k) == Int64
#                     df[!,i] = replace(df[!,i], nothing => 0)
#                 elseif typeof(k) == String
#                     df[!,i] = replace(df[!,i], nothing => "Missing")
#                 elseif typeof(k) == Bool
#                     df[!,i] = replace(df[!,i], nothing => false)
#                 end
#             end
#         end
#     elseif dummy == nothing
#     else
#         println(i)
#         for j in eachindex(dummy)
#             if typeof(dummy[j]) == Float64
#                 df[!,i][j] = replace(df[!,i][j], nothing => 0.0)
#             elseif typeof(dummy[j]) == Int64
#                 df[!,i] = replace(df[!,i][j], nothing => 0)
#             elseif typeof(dummy[j]) == String
#                 df[!,i] = replace(df[!,i][j], nothing => "Missing")
#             elseif typeof(dummy[j]) == Bool
#                 df[!,i] = replace(df[!,i][j], nothing => false)
#             end
#         end
#     end
# end



# df



# function Makie.plot(P::Type{<: AbstractPlot}, fig::Makie.FigurePosition, arg::Solution; axis = NamedTuple(), kwargs...)

#     menu = Menu(fig, options = ["viridis", "heat", "blues"])

#     funcs = [sqrt, x->x^2, sin, cos]

#     menu2 = Menu(fig, options = zip(["Square Root", "Square", "Sine", "Cosine"], funcs))

#     fig[1, 1] = vgrid!(
#         Label(fig, "Colormap", width = nothing),
#         menu,
#         Label(fig, "Function", width = nothing),
#         menu2;
#         tellheight = false, width = 200)

#     ax = Axis(fig[1, 2]; axis...)

#     func = Node{Any}(funcs[1])

#     ys = @lift($func.(arg.data))

#     scat = plot!(ax, P, Attributes(color = ys), ys)

#     cb = Colorbar(fig[1, 3], scat)

#     on(menu.selection) do s
#         scat.colormap = s
#     end

#     on(menu2.selection) do s
#         func[] = s
#         autolimits!(ax)
#     end

#     menu2.is_open = true

#     return Makie.AxisPlot(ax, scat)
# end

# # nrow = size(df)[1]
# # df_mod = DataFrame()
# # for i in names(df)

# #     if df[!,i][1] isa Dict
# #         #initialize an array nrow x length of the dict
# #         A = Array{Any}(undef,nrow,length(df[!,i][1]))
# #         key_list = []
# #         for k in keys(df[!,i][1])
# #             println("====")
# #             println(i)
# #             push!(key_list,k)
# #             println(k)
# #         end
# #     end
# # end

# #         for j in eachindex(df[!,i])
# #             println(j)
# #             #j is a dict
# #             for (k,v) in df[!,i][j]
# #                 #k is a sub name
# #                 println(k)
# #                 new_name = i * "_" * k
# #                 println(v)
# #                 if new_name ∉ names(df_mod)
# #                     T = typeof(v)
# #                     dummy = Vector{T}

# #                     df_mod[!,new_name] =Vector{T,undef,size(df)[1]}
# #                 end
# #                 df_mod[!,new_name] = push!(df_mod[!,new_name],v)
# #             end
# #         end
# #     end
# # end

            
# #         end
# #     elseif df[!,i][1] isa Vector
# #     else
# #         df_mod[!,i] = copy(df[!,i])
# #     end
# # end

# # for i in names(df)
# #     println(i,"::", typeof(df[!,i]))
# # end



# f = Figure();
# lines(f[1, 1], Solution(0:0.3:10))
# scatter(f[1, 2], Solution(0:0.3:10))
# f |> display





# select!(df, Not(:dp_rating)) 



# a = select!(df, Not([1]))
# a = select!(df, Not([2]))
# dfm = replace!(df,  => nothing)


# CSV.write("EC3.csv", df)


# #initialize a list of data
# latitudes = Vector{Float64}()
# longitudes = Vector{Float64}()
# concrete_strength = Vector{Float64}()
# gwp = Vector{Float64}()
# declared_unit = Vector{String}()

# for i in df.plant_or_group
#     push!(latitudes, i["latitude"])
#     push!(longitudes, i["longitude"])
# end
# concrete_strength_raw = df.concrete_compressive_strength_28d
# #find element that is nothing
# for i in 1:length(concrete_strength)
#     if concrete_strength_raw[i] == nothing
#         concrete_strength_raw[i] = "0"
#     end
# end
# concrete_strength = split.(concrete_strength_raw)
# #get only the first column of the array
# concrete_strength = [ parse(Float64, (i[1])) for i in concrete_strength]

# gwp_raw = df.gwp_per_category_declared_unit

# gwp = split.(gwp_raw)
# #get only the first column of the array
# gwp = [ parse(Float64, (i[1])) for i in gwp]
# declared_unit_raw = df.declared_unit
# declared_unit = split.(declared_unit_raw)
# #get only the first column of the array
# declared_unit = [ parse(Int64, i[1]) for i in declared_unit]
# norm_gwp = gwp ./ declared_unit
# # latitudes = df.plant_or_group[1]["latitude"]


# ##
# using GeoMakie , GLMakie
# lons = -180:180
# lats = -90:90
# slons = rand(lons, 2000)
# slats = rand(lats, 2000)
# sfield = [exp(cosd(l)) + 3(y/90) for (l,y) in zip(slons, slats)]

# fig = Figure()
# ax = GeoAxis(fig[1,1])
# scatter!(longitudes, latitudes; color = concrete_strength, markersize = norm_gwp./maximum(norm_gwp)*10)
# fig
# ##

# #scatter plot between gwp and concrete strength
# ax = Axis(fig[1,1], xlabel = "GWP [kgCO2e/m3]", ylabel = "concrete strength [MPa]")
# scatter!(ax, gwp, concrete_strength, markersize = norm_gwp./maximum(norm_gwp)*10)

# #do latitude, longitude, concrete strength at 28 days , gwp gwp_per_category_declared_unit, declared declared_unit

# "cementitious"
# "recycled_content" 
# compressive_strength
# fire_rating
# standard_deviation
# created_on
# updated_on

# compressive_strength
# concrete_aggregate_size_max
# concrete_air_entrain  #worth keeping
# concrete_co2_entrain #worth keeping
# concrete_compressive_strength_28d #good
# concrete_compressive_strength_other
# concrete_compressive_strength_other_d
# concrete_flexion_strength
# concrete_max_slump
# concrete_min_pipeline_size
# concrete_min_slump
# concrete_self_consolidating
# concrete_slump
# concrete_w_c_ratio
# gwp #good
# gwp_per_category_declared_unit #good
# gwp_per_kg
# gwp_z
# mass_per_declared_unit
# name 
# owner
# recycled_content
# declared_unit #good
# zzz.plant_or_group[1]["address_line"]
# zzz.plant_or_group[1]["latitude"]
# zzz.plant_or_group[1]["longitude"]

# lowest_plausible_gwp
# data = JSON.parse(filepath*filename)
# jtable = jsontable(filepath*filename)
# #join that to the rest of the files.
# #loop all files from page number.
# # turn json table into DataFrame
# df = DataFrame(jtable)
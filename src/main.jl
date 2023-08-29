###########
#Run this after all the files are scraped. (getdata.jl)
# include("getdata.jl")

include("mergefiles.jl") # This will output "dfsingle" and "dftidy" dataframes
#have to work with dfsingle
include("utilities.jl")

include("tidy.jl")
include("utilities\\map2.jl")


#should get 138400 x 328
df = joindata() # a placeholder (don't mess with this!)
dftidy = deepcopy(df) #mess with this instead!

println("There are ", size(df)[1], " data points in the dataframe")


#tidy up the dataframe by removing columns with only "nothing"
keep_columns1 = check1(df) 



# tidy will have 199 columns
df_tidy1 = df[!,keep_columns1]
println("There are ", size(df_tidy1)[1], " data points in the tidy dataframe")
println(describe(df_tidy1))

# visualizing columns with "nothing" only
df_nothing1 = df[!,keep_columns1.==0] 
println(describe(df_nothing1))
println(describe(df_tidy1))

#work with df_tidy1.
#checking for columns with vector/dict
keep_columns2 , singletype_columns = check2(df_tidy1)

#11 gone, 188 left.
df_tidy2 = df_tidy1[!,keep_columns2]
df_nothing2 = df_tidy1[!,keep_columns2.==0] 
df_single = df_tidy1[!, singletype_columns .&& keep_columns2]
df_multi = df_tidy1[!, singletype_columns .== 0 .&& keep_columns2]
println(describe(df_tidy2)) #188 columns
println(describe(df_nothing2)) #11 columns
println(describe(df_single)) #163 columns
println(describe(df_multi)) #25 columns

CSV.write("singletype.csv", df_single) #163 columns
# CSV.write("multitype.csv", df_multi) #25 columns

#DONE first pass.

###Now, we can freely select values in df_single.

# but have to tie them to location.

#get location and add to single type
# locations are in df_multi
countries = Vector{String}()
has_plant_or_group = Vector{Bool}(undef, size(df_multi))
has_owned_by = Vector{Bool}(undef, size(df_multi))
c1 = 0 
c2 = 0
c3 = 0
plant_or_group_ok = Vector{Bool}(undef, size(df_multi,1))
getout = false
for i in eachindex(df_multi[!,"plant_or_group"])
    if getout 
        break
    end
    plant_or_group_ok[i] = false
    dicti = df_multi[i,"plant_or_group"]
    try
        if !haskey(dicti, "country")
            #use "owned_by" instead
            println("#####")
            #inside "owned_by"
            #latitude, longitude
            #useful info : 
            # web_domain
            # name
            # address
            # created on ****
            # updated_on ****
            # website

            for j in keys(dicti["owned_by"]["location"])
                println(j , ":",dicti["owned_by"]["location"[j]])
                getout = true
    
            end
            break
            
        else
            plant_or_group_ok[i] = true
            # country
            # carbon_intensity
            # latitudes
            # longitude
        end

        c2  +=1
    catch
        c3  +=1
    end

end

@label here
 #only 5449 has plant_or_group -> country

#now we tidy up df_single
println(describe(df_single)) #163 columns




#first pass, remove nothing columns

#Work on Dictionaries and Vector (df_tidy2 or df_multi.)
#let's focus on "plant_or_group" column
plant_or_group = df_tidy2[!,"plant_or_group"]
# k = keys(plant_or_group[1]) #40 keys and 25 keys
#plant_or_group_40
#plant_or_group_25
address = Vector{Any}()
country = Vector{Any}()
carbon_intensity = Vector{String}()
created_on = Vector{String}()
lat = Vector{Float64}()
long = Vector{Float64}()
missingcol = Vector{Int64}()
for i in eachindex(plant_or_group)
    if plant_or_group[i] !== nothing
    # println(i)
        try
            k = keys(plant_or_group[i])
            push!(address,plant_or_group[i]["address"])
            push!(country,plant_or_group[i]["country"])
            push!(carbon_intensity,plant_or_group[i]["carbon_intensity"])
            push!(created_on,plant_or_group[i]["created_on"])
            push!(lat,plant_or_group[i]["latitude"])
            push!(long,plant_or_group[i]["longitude"])

            # country = plant_or_group[i]["country"]
            # carbon_intensity = plant_or_group[i]["carbon_intensity"]
            # created_on = plant_or_group[i]["created_on"]   
            # lat = plant_or_group[i]["latitude"]
            # long = plant_or_group[i]["longitude"]

        catch 
            k = keys(plant_or_group[i])
            # println(k)
            if length(k) == 25
                push!(address,"Missing")
                push!(country,plant_or_group[i]["owned_by"]["country"])
                push!(carbon_intensity, "0")
                push!(created_on,plant_or_group[i]["created_on"])
                push!(lat,0.)
                push!(long,0.)
            end
        end
    else
        println(i , " is missing")
        push!(missingcol,i)
        push!(address,"Missing")
        push!(country,"Missing")
        push!(carbon_intensity, "0")
        push!(created_on,"Missing")
        push!(lat,0.) 
        push!(long,0.)
    end
end

country_fullname = Vector{String}(undef, size(country))
for i in eachindex(country)
    try
    country_fullname[i] = country_maps[country[i]]
    catch 
        println(country[i])
end
end


#find nothing in all of the vector and replace them with approprate values
for i in eachindex(address)
    if address[i] === nothing
        address[i] = "Missing"
    end
    if country[i] === nothing
        country[i] = "Missing"
    end
    if carbon_intensity[i] === nothing
        carbon_intensity[i] = "0"
    end
    if created_on[i] === nothing
        created_on[i] = "Missing"
    end
    if lat[i] === nothing
        lat[i] = 0.
    end
    if long[i] === nothing
        long[i] = 0.
    end
end

dfsingle[!,"address"] = address
dfsingle[!,"country"] = country
dfsingle[!,"carbon_intensity"] = carbon_intensity
dfsingle[!,"created_on"] = created_on
dfsingle[!,"lat"] = lat
dfsingle[!,"long"] = long

CSV.write("singletype_loc.csv", dfsingle) #174 columns



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
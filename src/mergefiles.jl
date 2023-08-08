#tidy up files in the rawdata folder into a dataframe
using DataFrames, JSONTables, CSV
using JSON


function joindata()
    filepath = joinpath(@__DIR__,"rawdata\\")
    total_data = Vector{Any}()
    #first, get the total number of pages

    total_pages = size(readdir(filepath))[1]
    pages = 1:total_pages
    #could also multi thread this if slow
    @time for i in pages
        page_num = string(i)
        spg = "0"^(4 - length(page_num)) * page_num
        filename = "pg" * spg * ".json"
        vec1 = Vector{Any}()
        open(filepath*filename, "r") do f
            txt = JSON.read(f,String)  # file information to string
            vec1=JSON.parse(txt)  # parse and transform data
        end
        total_data = vcat(total_data,vec1)
    end
    df = DataFrame(total_data);
    return df
end

#should get 138400 x 328
df = joindata()
dftidy = deepcopy(df)


println("There are ", size(df)[1], " data points in the dataframe")
union_types(x::Union) = (x.a, union_types(x.b)...)
union_types(x::Type) = (x,)
#Tidy up the dataset.
#go through each column in df
#if the value in that column is a vector 
# create a new column, with the first column name follows by "_" then the sub column name 
# if the value is null, or false, turn them into either "" or 0.0, or 0, depend on the type of that column


colnames = names(df)
keep_columns = ones(Bool, length(colnames))
singletype_columns = zeros(Bool,length(colnames))

begin
for i in eachindex(colnames)
    name = colnames[i]

    #get the types of the column
    types = collect(union_types(eltype(df[!,i])))

    #check if there is more than 2 types in the column
    if size(types)[1] > 2 
        println(size(types))
        println("Column $i has more than 2 types")
    end

    #check column with only nothing
    if (Nothing in types)  & (size(types)[1] == 1)
        # println("Column $i is a vector of nothing")
        keep_columns[i] = false
        #THIS PART IS DONE
    else
        Ts = [String, Bool, Int64, Float64]
        Tsval = ["", false, 0, 0.0]
        if size(types)[1] == 2  #probably nothing and something
            for ti in eachindex(Ts)
                t = Ts[ti]
                valt = Tsval[ti]
                if t in types
                    #initiate the whole column in to a vector of a single type, 
                    #then replace the original column with the vector
                    vec = Vector{t}(undef, size(df)[1])
                    for j in eachindex(df[!,i])
                        if df[j,i] === nothing
                            vec[j] = valt
                        else
                            vec[j] = df[j,i]
                        end
                    end
                    dftidy[!,i] = vec
                end
                break
            end
    
            # if (String in types)
        elseif size(types)[1] > 2
            println("Column $i has more than 2 types")
            println("Please recheck the data")
        end
    end
end

for i in eachindex(colnames)
    name = colnames[i]
    println(name)

    # println(i)
    #check if there is a vector in the column
    #criterias to remove a column
    types = collect(union_types(eltype(dftidy[!,i])))
    # println("     ",types)
    if size(types)[1] > 2 
        println(size(types))
        println("Column $i has more than 2 types")
    end

    if (Nothing in types)  & (size(types)[1] == 1)
        println("*",name)
        # println("Column $i is a vector of nothing")
        keep_columns[i] = false
        #THIS PART IS DONE
    else 
        println(name)
    end


    # println("Column $i is ", types)
    if size(types)[1] == 1 
        # println("Column $i is ", types)
        if types[1] == String
            singletype_columns[i] = true
        elseif types[1] == Bool
            singletype_columns[i] = true
        elseif types[1] == Int64
            singletype_columns[i] = true
        elseif types[1] == Float64
            singletype_columns[i] = true
            # println("$i is " ,types)
        elseif isa(types[1] , Dict)
        else
    end
        # println("Column $i is a vector of ", types)
    end

 
    if all(dftidy[!,i] .== 0) || all(dftidy[!,i] .== "") || all(dftidy[!,i] .== false)
        println("All nothing at ", i , " ", name)
        keep_columns[i] = false
    end

end

end #of the begin


removed_names = colnames[keep_columns.==0]
keep_names = colnames[keep_columns.==1]
multi_types = colnames[keep_columns .* (singletype_columns.==0)]

#first pass, remove nothing columns

# 174 columns kept
dfsingle = dftidy[:,singletype_columns]

#go through each column in df
#if all of the values is 0 or "" or false, remove that column



dftidy[!,keep_columns]
#save to a csv file

CSV.write("singletype.csv", dfsingle) #174 columns

#There is still problem with any

#let's focus on "plant_or_group" column

plant_or_group = dftidy[!,"plant_or_group"]
# k = keys(plant_or_group[1]) #40 keys and 25 keys
#plant_or_group_40
#plant_or_group_25
address = Vector{Any}()
country = Vector{Any}()
carbon_intensity = Vector{String}()
created_on = Vector{String}()
lat = Vector{Float64}()
long = Vector{Float64}()

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
        push!(address,"Missing")
        push!(country,"Missing")
        push!(carbon_intensity, "0")
        push!(created_on,"Missing")
        push!(lat,0.) 
        push!(long,0.)
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
#         keep_columns[i] = false
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
using DataFrames, CSV, JSON
using Makie, GLMakie

include("utilities.jl") ;
#load the file
filepath = joinpath(@__DIR__)*"\\ECS_page_all.json"
open(filepath, "r") do f
    txt = JSON.read(f,String)  # file information to string
    global total_data=JSON.parse(txt)  # parse and transform data
end
#create a dataframe from the file
df1 = DataFrame(total_data)
#Check the dataframe
#should get 146800 x 351
println(size(df1))

#Get column names
n1 = names(df1)

#Find columns that have dictionaries
dicts = Vector{String}()
for i in eachindex(n1) #loop the names
    name = n1[i] #get the name
    col = df1[!,name] #get the value of the column
    T = typeof(col) #check type of that column (Vector{Something})
    eT = eltype(col) #check the element type of that column (Something)
    println(name, " ",eT)
    
    if eT === Dict()
        # println("DICT ",name)
        dicts = vcat(dicts, name)
        # chk1 = vcat(chk1, true)
    elseif eT === nothing # discard it
        # println("Nothing")
        continue
    #it will be Any type, so let's check the first one (risky but ok)
    # elseif col[1] isa Float64|| col[1] isa String || col[1] isa Bool
    #     chk1[i] = true
    #     println(T)
    # elseif eT isa Union #will have to check inside more.
    #     # chk1 = vcat(chk1, true)
    #     #will have to change nohting into something based on the other pair.
    #     # println(eT)
    # elseif col[1] isa Vector
    #     #Check the size, in case it has something,
    #     #currently, it has nothing.
    #     # for j in eachindex(col)
    #     #     if size(col[j])[1] ==0
    #     #         println("HI")
    #     #     break
    #     #     end
    #     # end
    #     # chk1 = vcat(chk1, false)

    elseif eT isa Any
        # chk1[i] = true
    else
        # println("###",eT)
    end
end

#Extract those dicts out.
df2 = df1[:,dicts]

# owned_by location country
#owne by has to be solved.
#location also have to be solved
# for i in eachindex(df2_dict)
cnames = Vector{String}(undef, size(df2)[1])
countries = Vector{String}(undef, size(df2)[1])
for i = 1:size(df2)[1]
    try
    cnames[i] = df2[!, "plant_or_group"][i]["owned_by"]["name"]
    catch
        println("missing ",i)
        cnames[i] = "Missing"
        println("fixed")
    end

    try
        countries[i] = df2[!, "plant_or_group"][i]["owned_by"]["location"]["country"]
    catch
        try
            # println(i)
            countries[i] = df2[!,"plant_or_group"][i]["country"]
            
        catch
            try
                countries[i] = df2[!,"plant_or_group"][i]["owned_by"]["country"]
            catch
                try
                
                countries[i] = df2[!, "plant_or_group"][i]["owned_by"]["locality"]
                catch
                    println(i, " is missing")
                    countries[i] = "Missing"
                end
            end
        end
    end    
end



str28d, str28d_u = getstr(df1,"concrete_compressive_strength_28d");
strotherday , strotherday_u = getstr(df1,"concrete_compressive_strength_other_d", warn = false);   
strother, strother_u = getstr(df1,"concrete_compressive_strength_other", warn = false);

println("done getting str")

fc = Vector{Float64}(undef, size(df1)[1])
for i in eachindex(str28d)
    if str28d_u[i] == "psi"
        fc[i] = str28d[i]*0.00689476
        # str28d_u[i] = "mpa"
    elseif str28d_u[i] == "mpa" || str28d_u[i] == "-"
        fc[i] = str28d[i]
    else
        println(String(str28d_u[i]))
    end
end

#get embodied carbon



gwp, gwp_u = getgwp(df1,"gwp_per_kg")

#check units
for i in eachindex(gwp)
    if gwp_u[i] != "kgco2e" && gwp_u[i] != "-"
        println(gwp[i])
        println(gwp_u[i])
    end
    if gwp[i] > 20.
        gwp[i] = 0
        gwp_u[i] = "-"
    end
end

#set gwp to 0 when fc is 0
for i in eachindex(gwp)
    if str28d[i] == 0.
        gwp[i] = 0.
        gwp_u[i] = "-"
    end
end

#count str that's below 20
count = 0
for i in eachindex(str28d)
    if str28d[i] < 20.
        count += 1
    end
end


latitude = Vector{Float64}(undef, size(df1)[1])
longitude = Vector{Float64}(undef, size(df1)[1])

for i = 1:size(df1)[1]
    try
        latitude[i] = df1[i,"plant_or_group"]["latitude"]
        longitude[i] = df1[i,"plant_or_group"]["longitude"]
    catch
        try
        latitude[i] = df1[i,"plant_or_group"]["owned_by"]["latitude"]
        longitude[i] = df1[i,"plant_or_group"]["owned_by"]["longitude"]
        catch 
            println(i)
        end
    end
end


#count is  26938 entries.
# get name of those entries

#create a new dataframe from these data
df_f  = DataFrame()
df_f[!, "fc"] = fc
df_f[!, "str28d"] = str28d
df_f[!, "str28d_u"] = str28d_u
df_f[!, "strotherday"] = strotherday
df_f[!, "strotherday_u"] = strotherday_u
df_f[!, "strother"] = strother
df_f[!, "strother_u"] = strother_u
df_f[!, "gwp"] = gwp
df_f[!, "gwp_u"] = gwp_u
df_f[!, "names"] = df1[!, "name"]
df_f[!, "latitude"] = latitude
df_f[!, "longitude"] = longitude
df_f[!, "country"] = countries
df_f[!, "cnames"] = cnames
filename = "df_f.csv"
CSV.write(filename, df_f)




"""

split.(df2[!, "standard_deviation"]," ") #will have to cut kgCo2e out
plant_or_group -> carbon_intensity 
plant_or_group -> owned_by -> name
plant_or_group -> owned_by -> latitude. longitude.
plant_or_group -> country
plant_or_group -> latitude, longitude
best_practice
gwp_per_category_declared_unit
density
gwp split
declared_unit (split)
conservative_estimate splt

select from df1
"fiber_reinforced": true

concrete_compressive_strength_28d
concrete_compressive_strength_other (have to mark special)
concrete_compressive_strength_other_d

gwp_per_kg


Cat = df1[!, "category"]
df2 = deepcopy(df1)
l = 44
yes = false
for (k,v) in Cat[1]
println(k)
end


for i in eachindex(Cat)
    cat = Cat[i]
    if length(cat) != l #check length of the dict. make sure that keys are the same.
        println(cat)
    end
    for (k,v) in cat
        if v isa String
            if 
            df2[!, "c_"*k] = Vector{String}(undef, size(df2)[1])
            #create new col as "c_"*k
        elseif v isa Bool
        elseif v isa Float64


        # elseif size(v)== 0
        elseif v isa Nothing
        elseif v isa Any
            # if size(v)[1] > 0 
            #     println(v)
            # end
        else
            println(v)
            # println(size(v)[1])
            # yes = true
            # println(v)
            # println(typeof(v))
        end
        # if yes
        #     break
        # end

    end
end



    if eT == Nothing 
        # println("Nothing")
        chk1 = vcat(chk1, false)
    elseif eT isa Vector
        println("###")
        eeT = eltype(eT)
        if eT == Nothing
            chk1 = vcat(chk1, false)
        elseif eT isa Dict
            chk1 = vcat(chk1, true)
        else
            chk1 = vcat(chk1, true)
            # println(eT)
        end
    elseif eT isa Dict
        chk1 = vcat(chk1, true)
        println(eT)
        break
    else 
        chk1 = vcat(chk1, true)
        println("#",eT)
    end
    # println(i, " is ", T)
end

#Now we work only with the non nothing type columns
df2 = df1[:,chk1]

chk2 = Vector{Bool}()
keep = ["String", "Float64", "Int64", "Bool"]
for i in names(df)
    # println(i)
    t = string(typeof(df[!,i]))

    start = findfirst("{" , t)
    stop = findlast("}", t)
    
    if isnothing(start)
        #the type does not have {} anymore, so it must be non Dict/Vec/Union type
        println("Help")
        chk2=vcat(chk2, true)
    else
        #The type is a Vector/Dict of something
        tinner = t[start[1]+1:stop[1]-1]
        start2 = findfirst("{" , tinner)
        stop2 = findlast("}", tinner)
        if isnothing(start2)
            chk2=vcat(chk2, true)
        else 
            tinner2 = tinner[start2[1]+1:stop2[1]-1]
            println(tinner2)
            chk2=vcat(chk2, false)
        end
    end
end

@assert length(chk1) == length(chk2)

chk = chk1.*chk2

for i in chk
    println(Int(i))
end

df1 = df[:,chk]

dfv = df[:, chk2]

limit = 100
small_columns = []
for i in names(df) 
    if typeof(df[!,i]) != Float64 || typeof(df[!,i]) != Int64
        println(i)
        println(typeof(df[!,i]))
        # println(sum(df[!,i].!= nothing))
        if sum(df[!,i].!= nothing) <=limit
            if i ∉ small_columns 
                push!(small_columns,i)
            end
        end
    end
end

dummy = size(small_columns)[1]
println("Number of small columns (less than $limit): $dummy")

list_of_names = names(df)
sort!(list_of_names)

#go through every single elements of df, 
# check the type of each vector, to replace nothing with "" or 0.0 or 0
function replace_nothing!(df)
end


for i in names(df)
    dummy = df[!,i][1]
    if dummy isa Dict
    elseif dummy isa Vector
        for j in df[!,i]
            for k in j
                if typeof(k) == Float64
                    df[!,i] = replace(df[!,i], nothing => 0.0)
                elseif typeof(k) == Int64
                    df[!,i] = replace(df[!,i], nothing => 0)
                elseif typeof(k) == String
                    df[!,i] = replace(df[!,i], nothing => "None")
                elseif typeof(k) == Bool
                    df[!,i] = replace(df[!,i], nothing => false)
                end
            end
        end
    elseif dummy == nothing
    else
        println(i)
        for j in eachindex(dummy)
            if typeof(dummy[j]) == Float64
                df[!,i][j] = replace(df[!,i][j], nothing => 0.0)
            elseif typeof(dummy[j]) == Int64
                df[!,i] = replace(df[!,i][j], nothing => 0)
            elseif typeof(dummy[j]) == String
                df[!,i] = replace(df[!,i][j], nothing => "None")
            elseif typeof(dummy[j]) == Bool
                df[!,i] = replace(df[!,i][j], nothing => false)
            end
        end
    end
end



df



function Makie.plot(P::Type{<: AbstractPlot}, fig::Makie.FigurePosition, arg::Solution; axis = NamedTuple(), kwargs...)

    menu = Menu(fig, options = ["viridis", "heat", "blues"])

    funcs = [sqrt, x->x^2, sin, cos]

    menu2 = Menu(fig, options = zip(["Square Root", "Square", "Sine", "Cosine"], funcs))

    fig[1, 1] = vgrid!(
        Label(fig, "Colormap", width = nothing),
        menu,
        Label(fig, "Function", width = nothing),
        menu2;
        tellheight = false, width = 200)

    ax = Axis(fig[1, 2]; axis...)

    func = Node{Any}(funcs[1])

    ys = @lift($func.(arg.data))

    scat = plot!(ax, P, Attributes(color = ys), ys)

    cb = Colorbar(fig[1, 3], scat)

    on(menu.selection) do s
        scat.colormap = s
    end

    on(menu2.selection) do s
        func[] = s
        autolimits!(ax)
    end

    menu2.is_open = true

    return Makie.AxisPlot(ax, scat)
end

# nrow = size(df)[1]
# df_mod = DataFrame()
# for i in names(df)

#     if df[!,i][1] isa Dict
#         #initialize an array nrow x length of the dict
#         A = Array{Any}(undef,nrow,length(df[!,i][1]))
#         key_list = []
#         for k in keys(df[!,i][1])
#             println("====")
#             println(i)
#             push!(key_list,k)
#             println(k)
#         end
#     end
# end

#         for j in eachindex(df[!,i])
#             println(j)
#             #j is a dict
#             for (k,v) in df[!,i][j]
#                 #k is a sub name
#                 println(k)
#                 new_name = i * "_" * k
#                 println(v)
#                 if new_name ∉ names(df_mod)
#                     T = typeof(v)
#                     dummy = Vector{T}

#                     df_mod[!,new_name] =Vector{T,undef,size(df)[1]}
#                 end
#                 df_mod[!,new_name] = push!(df_mod[!,new_name],v)
#             end
#         end
#     end
# end

            
#         end
#     elseif df[!,i][1] isa Vector
#     else
#         df_mod[!,i] = copy(df[!,i])
#     end
# end

# for i in names(df)
#     println(i,"::", typeof(df[!,i]))
# end



f = Figure();
lines(f[1, 1], Solution(0:0.3:10))
scatter(f[1, 2], Solution(0:0.3:10))
f |> display





select!(df, Not(:dp_rating)) 



a = select!(df, Not([1]))
a = select!(df, Not([2]))
dfm = replace!(df,  => nothing)


CSV.write("EC3.csv", df)


#initialize a list of data
latitudes = Vector{Float64}()
longitudes = Vector{Float64}()
concrete_strength = Vector{Float64}()
gwp = Vector{Float64}()
declared_unit = Vector{String}()

for i in df.plant_or_group
    push!(latitudes, i["latitude"])
    push!(longitudes, i["longitude"])
end
concrete_strength_raw = df.concrete_compressive_strength_28d
#find element that is nothing
for i in 1:length(concrete_strength)
    if concrete_strength_raw[i] == nothing
        concrete_strength_raw[i] = "0"
    end
end
concrete_strength = split.(concrete_strength_raw)
#get only the first column of the array
concrete_strength = [ parse(Float64, (i[1])) for i in concrete_strength]

gwp_raw = df.gwp_per_category_declared_unit

gwp = split.(gwp_raw)
#get only the first column of the array
gwp = [ parse(Float64, (i[1])) for i in gwp]
declared_unit_raw = df.declared_unit
declared_unit = split.(declared_unit_raw)
#get only the first column of the array
declared_unit = [ parse(Int64, i[1]) for i in declared_unit]
norm_gwp = gwp ./ declared_unit
# latitudes = df.plant_or_group[1]["latitude"]


##
using GeoMakie , GLMakie
lons = -180:180
lats = -90:90
slons = rand(lons, 2000)
slats = rand(lats, 2000)
sfield = [exp(cosd(l)) + 3(y/90) for (l,y) in zip(slons, slats)]

fig = Figure()
ax = GeoAxis(fig[1,1])
scatter!(longitudes, latitudes; color = concrete_strength, markersize = norm_gwp./maximum(norm_gwp)*10)
fig
##

#scatter plot between gwp and concrete strength
ax = Axis(fig[1,1], xlabel = "GWP [kgCO2e/m3]", ylabel = "concrete strength [MPa]")
scatter!(ax, gwp, concrete_strength, markersize = norm_gwp./maximum(norm_gwp)*10)

#do latitude, longitude, concrete strength at 28 days , gwp gwp_per_category_declared_unit, declared declared_unit

"cementitious"
"recycled_content" 
compressive_strength
fire_rating
standard_deviation
created_on
updated_on

compressive_strength
concrete_aggregate_size_max
concrete_air_entrain  #worth keeping
concrete_co2_entrain #worth keeping
concrete_compressive_strength_28d #good
concrete_compressive_strength_other
concrete_compressive_strength_other_d
concrete_flexion_strength
concrete_max_slump
concrete_min_pipeline_size
concrete_min_slump
concrete_self_consolidating
concrete_slump
concrete_w_c_ratio
gwp #good
gwp_per_category_declared_unit #good
gwp_per_kg
gwp_z
mass_per_declared_unit
name 
owner
recycled_content
declared_unit #good
zzz.plant_or_group[1]["address_line"]
zzz.plant_or_group[1]["latitude"]
zzz.plant_or_group[1]["longitude"]

lowest_plausible_gwp
data = JSON.parse(filepath*filename)
jtable = jsontable(filepath*filename)
#join that to the rest of the files.
#loop all files from page number.
# turn json table into DataFrame
df = DataFrame(jtable)
"""
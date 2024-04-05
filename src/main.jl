
#Load all required functions.
include("loadall.jl");

# scrapeit(all=true, path =fullpath)

#test merge files
# fullpath = "/Users/pitipatwongsittikan/dev/CarbonMines/src/rawdata_150802/"
fullpath = "//Users//pitipatwongsittikan//dev//CarbonMines//src//rawdata_129710//"

df = mergefiles(dummy = true, path = fullpath)  #If this line fails due to keys error, remove those keys (if those aren't the important ones)

if typeof(df) == DataFrame
    println("Merge successful")
else
    println("Merge failed")

removekey = ["sae_standards",
             "en_standards",
             "astm_standards"
            ]
for i in eachindex(df)
    for j in removekey
        delete!(df[i], j)
    end
end
df = DataFrame(df)
end


#should get 138400 x 328 (or N by 328) 
df = mergefiles(path = fullpath)
if typeof(df) == DataFrame
    println("Merge successful")
else
    println("Merge failed")

removekey = ["sae_standards",
             "en_standards",
             "astm_standards"
            ]
for i in eachindex(df)
    for j in removekey
        delete!(df[i], j)
    end
end
df = DataFrame(df)
end
# dftidy = deepcopy(df) #mess with this instead!
println("There are ", size(df)[1], " datapoints in the dataframe")

#tidy up the dataframe by removing columns with only "nothing"
keep_columns1 = check1!(df) 

# tidy will have 199 columns
df_tidy1 = df[!,keep_columns1];
println("There are ", size(df_tidy1)[1], " data points in the tidy dataframe")
# println(describe(df_tidy1));

# visualizing columns with "nothing" only
df_nothing1 = df[!,keep_columns1.==0] ;
# println(describe(df_nothing1));
# println(describe(df_tidy1));

#work with df_tidy1.
#checking for columns with vector/dict
keep_columns2 , singletype_columns = check2(df_tidy1);

#11 gone, 188 columns left.
df_tidy2 = df_tidy1[!,keep_columns2];
df_nothing2 = df_tidy1[!,keep_columns2.==0] ;

# CSV.write("multitype.csv", df_multi) #25 columns

###Now, we can freely select values in df_single.###

#get category column
category = df_tidy2[!, "category"]
othernames = []
for i in eachindex(category)
    n = lowercase(category[i]["name"])
    if !(n in othernames)
        push!(othernames, n)
    end
    if occursin("ready",n)
    else
        println(n)
    end

end

#get only concrete related datapoints
look_for = ["concrete", "readymix", "cement "]
keep_entry1 = Vector{Bool}(undef, size(df,1))
for i in eachindex(keep_entry1)
    n = lowercase(category[i]["name"]*" ")
    for j in look_for
        if occursin(j,n)
            keep_entry1[i] = true
             break
        else
            keep_entry1[i] = false
        end
    end
end

n_keep_entry1 = sum(keep_entry1)
println("There are $n_keep_entry1 columns which relate to concrete")

namess = []
for i in eachindex(keep_entry1)
    if keep_entry1[i]
        # println(category[i]["name"])
        push!(namess, category[i]["name"])
    
    else
    end
end

println("selected names")
for i in unique(namess)
    println(i)
end


df_tidy3 = df_tidy2[keep_entry1,:]
df_single = df_tidy1[keep_entry1, singletype_columns .&& keep_columns2];
df_multi = df_tidy1[keep_entry1, singletype_columns .== 0 .&& keep_columns2];

df_tidy3 = df_tidy2[keep_entry1,:]



#let's focus on "plant_or_group" column
plant_or_group = df_tidy3[!,"plant_or_group"];
# k = keys(plant_or_group[1]) #40 keys and 25 keys
#plant_or_group_40
#plant_or_group_25
address = Vector{Any}();
country = Vector{Any}();
carbon_intensity = Vector{String}();
created_on = Vector{String}();
lat = Vector{Float64}();
long = Vector{Float64}();
missingcol = Vector{Int64}();
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
        println("Entry ", i , " is missing location info")
        push!(missingcol,i)
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

country_fullname = Vector{String}(undef, size(country));
for i in eachindex(country)
    try
    country_fullname[i] = country_maps[country[i]]
    catch 
        println(country[i])
end
end

IDs = Vector{String}(undef, size(df_tidy3)[1])
for i in eachindex(IDs)
    # println(i)
    IDs[i] = df_tidy3[i,"id"]
end


owned_by = Vector{String}(undef, size(df_tidy3)[1])
for i in eachindex(owned_by)
    # println(i)
    owned_by[i] = df_tidy3[i,"plant_or_group"]["owned_by"]["name"]
end



df_single[!,"ID"] = IDs;
df_single[!,"owned_by"] = owned_by;
df_single[!,"address"] = address;
df_single[!,"country"] = country;

df_single[!,"carbon_intensity"] = carbon_intensity;
df_single[!,"created_on"] = created_on;
df_single[!,"lat"] = lat;
df_single[!,"long"] = long;



filename = "0404_df_single.csv"
CSV.write(filename, df_single) ;#174 columns
checkpoint(df_single)
println("CSV file created at $filename")
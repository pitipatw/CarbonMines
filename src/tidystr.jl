using CSV


function getstr(df1, name; warn=true)
    println("#"^10)
    println("Getting STRENGTH values for " * name)
    vals = Vector{Float64}(undef, size(df1)[1])
    units = Vector{String}(undef, size(df1)[1])
    for i = 1:size(df1)[1]
        #check if "concrete_compressive_strength_28d" is there
        val = df1[i, name]
        # println(val)
        if typeof(val) != Nothing && val != "nothing" && val != "Missing"
            if val isa String
                # println(val)
                # println(typeof(val))
                try
                    vals[i] = parse(Float64, (split(val, " ")[1]))
                    if lowercase(split(val, " ")[2]) == "mpa" || lowercase(split(val, " ")[2]) == "psi"
                        units[i] = lowercase(split(val, " ")[2]) #this would be mpa and psi
                    else
                        try
                            #watchout for "  " , double space!
                            units[i] = lowercase(split(val, "  ")[2]) #this would be mpa and psi
                        catch
                            if warn
                                println("#"^5)
                                println("new unit, assigning 0 and - as units for now")
                            end
                            vals[i] = 0.0
                            units[i] = "-"
                            println(val)

                        end
                    end
                catch #there's no space between the value and unit
                    #MPa case
                    pos = findfirst("m", lowercase(val))[1]
                    if pos != nothing
                        #There is M (probably MPa) in the string
                        vals[i] = parse(Float64, (split(lowercase(val), "m")[1]))
                        if lowercase(val[pos:end]) == "mpa"
                            units[i] = "mpa"
                        else
                            if warn
                                println("#"^5)
                                println(val[pos:end])
                                println("new unit")
                            end
                        end
                    else
                        println("new unit")
                    end
                end
            else
                if warn
                    println("#"^5)
                    println("This is not a String, assigning 0 and - as units")
                    println("Value of the index is:")
                    println(val)
                end
                vals[i] = 0.0
                units[i] = "-"


            end
        elseif val == "Missing"
            vals[i] = 0.0
            units[i] = "-"
        else
            if warn
                println("#"^5)
                println("Weird type, assigning 0 and - as units")
                println("Value of the index is:", val)
                println("Type of the index is:", typeof(val))
            end
            vals[i] = 0.0
            units[i] = "-"

        end
    end
    println("#"^10)
    return vals, units

end


str28d, str28d_u = getstr(df, "concrete_compressive_strength_28d");
strotherday, strotherday_u = getstr(df, "concrete_compressive_strength_other_d", warn=false);
strother, strother_u = getstr(df, "concrete_compressive_strength_other", warn=false);

println("done getting str")

for i in eachindex(str28d)
    if str28d_u[i] == "psi"
        str28d[i] = str28d[i] * 0.00689476
        str28d_u[i] = "mpa"
    elseif str28d_u[i] == "mpa" || str28d_u[i] == "-"

    else
        println(String(str28d_u[i]))
    end
end

#get embodied carbon

function getgwp(df1, name; warn=true)
    println("#"^10)
    println("Getting GWP values for " * name)
    vals = Vector{Float64}(undef, size(df1)[1])
    units = Vector{String}(undef, size(df1)[1])
    for i = 1:size(df1)[1]

        #check if "concrete_compressive_strength_28d" is there
        val = df1[i, name]
        # println(val)
        if typeof(val) != Nothing && val != "nothing" && val != "Missing"
            if val isa String
                # println(val)
                # println(typeof(val))
                try
                    vals[i] = parse(Float64, (split(val, " ")[1]))
                    if lowercase(split(val, " ")[2]) == "kgco2e" #|| lowercase(split(val," ")[2]) == "psi"
                        units[i] = lowercase(split(val, " ")[2]) #this would be mpa and psi
                    else
                        try
                            #watchout for "  " , double space!
                            units[i] = lowercase(split(val, "  ")[2]) #this would be mpa and psi
                        catch
                            if warn
                                println("new unit, assigning 0 and - as units for now")
                            end
                            vals[i] = 0.0
                            units[i] = "-"
                            println(val)

                        end
                    end
                    units[i] = lowercase(split(val, " ")[2]) #this would be mpa and psi
                catch #there's no space between the value and unit
                    #MPa case
                    pos = findfirst("m", lowercase(val))[1]
                    if pos != nothing
                        #There is M (probably MPa) in the string
                        vals[i] = parse(Float64, (split(lowercase(val), "m")[1]))
                        if lowercase(val[pos:end]) == "mpa"
                            units[i] = "mpa"
                        else
                            if warn
                                println("#"^5)
                                println(val[pos:end])
                                println("new unit")
                            end
                        end
                    else
                        println("new unit")
                    end
                end
            else
                if warn
                    println("#"^5)
                    println("This is not a String, assigning 0 and - as units")
                    println("Value of the index is:")
                    println(val)
                end
                vals[i] = 0.0
                units[i] = "-"


            end
        elseif val == "Missing"
            vals[i] = 0.0
            units[i] = "-"
        else
            if warn
                println("#"^5)
                println("Weird type, assigning 0 and - as units")
                println("Value of the index is:", val)
                println("Type of the index is:", typeof(val))
            end
            vals[i] = 0.0
            units[i] = "-"

        end
    end
    println("#"^10)
    return vals, units

end

gwp, gwp_u = getgwp(df, "gwp_per_kg")

#check units
for i in eachindex(gwp)
    if gwp_u[i] != "kgco2e" && gwp_u[i] != "-"
        println(gwp[i])
        println(gwp_u[i])
    end
    if gwp[i] > 20.0
        gwp[i] = 0
        gwp_u[i] = "-"
    end
end

#set gwp to 0 when fc is 0
for i in eachindex(gwp)
    if str28d[i] == 0.0
        gwp[i] = 0.0
        gwp_u[i] = "-"
    end
end


#create a new dataframe from these data
dfsingle[!, "str28d"] = str28d
dfsingle[!, "str28d_u"] = str28d_u
dfsingle[!, "strotherday"] = strotherday
dfsingle[!, "strotherday_u"] = strotherday_u
dfsingle[!, "strother"] = strother
dfsingle[!, "strother_u"] = strother_u
dfsingle[!, "gwp"] = gwp
dfsingle[!, "gwp_u"] = gwp_u

CSV.write("singletype_loc.csv", dfsingle) #174 columns

dfcompact = DataFrame()
dfcompact[!, "str28d"] = str28d
dfcompact[!, "str28d_u"] = str28d_u
dfcompact[!, "strotherday"] = strotherday
dfcompact[!, "strotherday_u"] = strotherday_u
dfcompact[!, "strother"] = strother
dfcompact[!, "strother_u"] = strother_u
dfcompact[!, "gwp"] = gwp
dfcompact[!, "gwp_u"] = gwp_u
dfcompact[!,"address"] = address
dfcompact[!,"country"] = country
dfcompact[!,"carbon_intensity"] = carbon_intensity
dfcompact[!,"created_on"] = created_on
dfcompact[!,"lat"] = lat
dfcompact[!,"long"] = long

CSV.write("compact.csv", dfcompact)
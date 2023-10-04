using JLD2
using Dates
using DataFrames

function getstr(df1, name; warn = true)
    println("#"^10)
    println("Getting STRENGTH values for "*name)
vals = Vector{Float64}(undef, size(df1)[1])
units = Vector{String}(undef, size(df1)[1])
for i =1:size(df1)[1]
    #check if "concrete_compressive_strength_28d" is there
    val = df1[i,name]
    # println(val)
    if typeof(val) != Nothing && val != "nothing" && val != "Missing"
        if val isa String
            # println(val)
            # println(typeof(val))
            try
                vals[i] = parse(Float64,(split(val," ")[1]))
                if lowercase(split(val," ")[2]) == "mpa" || lowercase(split(val," ")[2]) == "psi"
                    units[i] = lowercase(split(val," ")[2]) #this would be mpa and psi
                else
                    try
                    #watchout for "  " , double space!
                    units[i] = lowercase(split(val,"  ")[2]) #this would be mpa and psi
                    catch
                        if warn 
                        println("#"^5)
                        println("new unit, assigning 0 and - as units for now")
                        end
                        vals[i] = 0.
                        units[i] = "-"
                        println(val)
                        
                    end
                end
            catch #there's no space between the value and unit
                #MPa case
                pos = findfirst("m",lowercase(val))[1]
                if  pos !== nothing
                    #There is M (probably MPa) in the string
                    vals[i] = parse(Float64,(split(lowercase(val),"m")[1]))
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
            vals[i] = 0.
            units[i] = "-"
            
            
        end
    elseif val == "Missing"
        vals[i] = 0.
        units[i] = "-"
    else
        if warn 
        println("#"^5)
        println("Weird type, assigning 0 and - as units")
        println("Value of the index is:", val)
        println("Type of the index is:", typeof(val))
        end
        vals[i] = 0.
        units[i] = "-"
        
    end
end
println("#"^10)
return vals, units
end



function getgwp(df1, name; warn = true)
    println("#"^10)
    println("Getting GWP values for "*name)
vals = Vector{Float64}(undef, size(df1)[1])
units = Vector{String}(undef, size(df1)[1])
for i =1:size(df1)[1]

    #check if "concrete_compressive_strength_28d" is there
    val = df1[i,name]
    # println(val)
    if typeof(val) != Nothing && val != "nothing" && val != "Missing"
        if val isa String
            # println(val)
            # println(typeof(val))
            try
                vals[i] = parse(Float64,(split(val," ")[1]))
                if lowercase(split(val," ")[2]) == "kgco2e" #|| lowercase(split(val," ")[2]) == "psi"
                    units[i] = lowercase(split(val," ")[2]) #this would be mpa and psi
                else
                    try
                    #watchout for "  " , double space!
                    units[i] = lowercase(split(val,"  ")[2]) #this would be mpa and psi
                    catch
                        if warn 
                        println("new unit, assigning 0 and - as units for now")
                        end
                        vals[i] = 0.
                        units[i] = "-"
                        println(val)
                        
                    end
                end
                units[i] = lowercase(split(val," ")[2]) #this would be mpa and psi
            catch #there's no space between the value and unit
                #MPa case
                pos = findfirst("m",lowercase(val))[1]
                if  pos != nothing
                    #There is M (probably MPa) in the string
                    vals[i] = parse(Float64,(split(lowercase(val),"m")[1]))
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
            vals[i] = 0.
            units[i] = "-"
            
            
        end
    elseif val == "Missing"
        vals[i] = 0.
        units[i] = "-"
    else
        if warn 
        println("#"^5)
        println("Weird type, assigning 0 and - as units")
        println("Value of the index is:", val)
        println("Type of the index is:", typeof(val))
        end
        vals[i] = 0.
        units[i] = "-"
        
    end
end
println("#"^10)
return vals, units

end

function plotacountry(df,c)
    f = Figure(resolution = (600,800))
    title = c
    #create axis for that country
    ax = Axis(f[1,1], title = title)
    # xlims!(ax, xlim[1], xlim[2])
    # ylims!(ax, 0,0.5)
    scatter!(ax, df[df[!,"country_map"].==title,"str28d"], df[df[!,"country_map"].==title, :][!, "gwp"], 
    markersize = 10, color = df[df[!,"country_map"].==title,"lat"])
    return f
end



function checkpoint(df::DataFrame)
    path = @__DIR__
    time = today()
    time = replace(string(time), "-" => "_")

    originalpath = path*"/checkpoints/checkpoint_"*time

    fullpath = originalpath*"_ver0.jld2"
    counter = 0
    duplicate = true
    while duplicate
        println(counter)
        if !isfile(fullpath)
            println("inside", counter)
            duplicate = false
            fullpath = originalpath*"_ver"*string(counter)*".jld2"
            jldsave(fullpath; df)
            println("checkpoint saved at ", fullpath)
        end
        counter += 1 
        fullpath = originalpath*"_ver"*string(counter)*".jld2"
        
    end

    println("To load, use:")
    println("load(\""*fullpath*"\")")
end



# df = DataFrame()
# df[!,"country"] = ["us", "us"]
# df[!,"gwp"] = [102, 211]


# checkpoint(df)

# df_load = load("E://dev//CarbonMines//src//checkpoints//checkpoint_2023_08_19_ver2.jld2")
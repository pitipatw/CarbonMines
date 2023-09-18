using JLD2
using Dates
using DataFrames
# using JSONTables

function checkpoint(df)
    path = @__DIR__
    time = today()
    time = replace(string(time), "-" => "_")

    originalpath = path*"\\src\\checkpoints\\checkpoint_"*time

    fullpath = originalpath*"_ver0.jld2"
    counter = 0
    duplicate = true
    while duplicate
        println(counter)
        if !isfile(fullpath)
            println("inside", counter)
            duplicate = false
            fullpath = originalpath*"_ver"*string(counter)*".jld2"
            println("checkpoint saved at ", fullpath)
            jldsave(fullpath; df)
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


function savepng( name::String, f1::Figure;
    path::String = "outputs\\")
    println("Current Directory is "*@__DIR__)
    save(path*name*".png" , f1)
    return f1
end

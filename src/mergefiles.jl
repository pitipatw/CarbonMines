#tidy up files in the rawdata folder and merge into a dataframe
using DataFrames, JSONTables, CSV
using JSON
using ProgressMeter

"""
    joindata()
    Go through rawdata folder and concat all the files into a dataframe
"""
function joindata()
    filepath = joinpath(@__DIR__,"rawdata\\")
    
    #first, get the total number of pages

    total_pages = size(readdir(filepath))[1]
    total_data = Vector{Any}(undef, total_pages)
    p = Progress(total_pages)
    update!(p,1)
    jj = Threads.Atomic{Int}(0)
    l = Threads.SpinLock()
    pages = 1:total_pages
    #could also multi thread this if slow
    @time Threads.@threads for i in pages
        page_num = string(i)
        spg = "0"^(4 - length(page_num)) * page_num
        filename = "pg" * spg * ".json"
        vec1 = Vector{Any}()
        open(filepath*filename, "r") do f
            txt = JSON.read(f,String)  # file information to string
            vec1=JSON.parse(txt)  # parse and transform data
        end
        # total_data = vcat(total_data,vec1)
        total_data[i] = vec1


        Threads.atomic_add!(jj, 1)
        Threads.lock(l)
        update!(p, jj[])
        Threads.unlock(l)  
    end
    total_data = vcat(total_data...)
    println("Done concating files")
    df = DataFrame(total_data);
    println("DONE")
    return df
end
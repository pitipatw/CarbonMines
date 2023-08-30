using DataFrames, JSONTables, CSV
using JSON
using ProgressMeter

"""
    joindata()
    Go through rawdata folder and concat all the files into a dataframe
    #tidy up files in the rawdata folder and merge into a dataframe
"""
function mergefiles()
    #get path to rawdata folder
    filepath = joinpath(@__DIR__,"rawdata\\")
    
    #get the total number of pages by number of files in the folder.
    total_pages = size(readdir(filepath))[1]
    total_data = Vector{Any}(undef, total_pages)

    #initiate progress bar for tracking progress
    p = Progress(total_pages)
    update!(p,1)
    jj = Threads.Atomic{Int}(0)
    l = Threads.SpinLock()

    pages = 1:total_pages
    #speed will depend on the number of threads
    println("Available threads: ",Threads.nthreads())
    @time Threads.@threads for i in pages
        # turn page number into string to append to get the filename
        page_num = string(i)
        #format page number to 4 digits (0001, 0002, etc.)
        spg = "0"^(4 - length(page_num)) * page_num
        filename = "pg" * spg * ".json"
        vec1 = Vector{Any}()
        open(filepath*filename, "r") do f
            txt = JSON.read(f,String)  # file information to string
            vec1=JSON.parse(txt)  # parse and transform data
        end
        # add data into the pre allocated array
        total_data[i] = vec1

        # update the progress bar
        Threads.atomic_add!(jj, 1)
        Threads.lock(l)
        update!(p, jj[])
        Threads.unlock(l)  
    end
    #concat all the data and turn into a dataframe
    total_data = vcat(total_data...)
    println("Done concating files")
    df = DataFrame(total_data);
    println("DONE")
    return df
end
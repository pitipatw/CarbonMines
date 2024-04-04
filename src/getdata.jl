# module GetData
using HTTP, JSON, DataFrames
using ProgressMeter

#Last run : 06/08/2023

#GOAL
#at the first loop, get the total number of pages
#get that by res["X-Total-Pages"]
#Each page will have 100 items, therefore loop from 1 to res["X-Total-Pages"]
#at each loop, get the data from the page
#save the data to a json file separate by the filename 
#filename = "ECS" * string(i) * ".json"

println("TO DO
Test files with the same name, after a couple of months, if they are the same, we can ignore running it\n 
and only run the new one.")

include("key.jl")

function get_data(cate::String, page::Int64
    ; token::String=token, mode::Int64=0)
    if mode == 0
        res = HTTP.request("GET",
            "https://buildingtransparency.org/api/$cate?page_number=$page", #materials?page_number=2",
            # "https://buildingtransparency.org/api/$cate?name__like=cement&page_number=$page", #materials?page_number=2",

            ["Authorization" => "Bearer " * "$token"]
        )
    else
        #different categories, or do something else
        println("Mode not found")
        res = 0.0
    end
    return res
end

function scrapeit(;all::Bool=false, total_pages::Int64=5, path = "rawdata/")
    cate = "materials"
    page = 1 #start from page 1

    filepath = joinpath(@__DIR__, path)

    if all 
        total_pages = parse(Int64, (res["X-Total-Pages"]))
        println("Scraping process started")
        println("There are :", total_pages, " pages")
    else
        println("Test Run Started")
        println("Scraping 5 pages")
    end

    #initialize variables
    p = Progress(total_pages)
    ProgressMeter.update!(p,1)
    jj = Threads.Atomic{Int}(0)
    l = Threads.SpinLock()

    Threads.@threads for page = 1:total_pages
        # sleep(5)
            # if page == 1 & total_pages != 10 #first run
            #     total_pages = parse(Int64, (res["X-Total-Pages"]))
            #     println("Scraping process started")
            #     println("There are :", total_pages, " pages")
            # end
        #get number to 0000 format for filename
        spg = "0"^(4 - length(string(page))) * string(page)
        filename = "pg" * string(spg) * ".json"

        if isfile(filepath * filename)
            println("Found file ", filename, "-> Skipped")
            Threads.atomic_add!(jj, 1)
            Threads.lock(l)
            ProgressMeter.update!(p, jj[])
            Threads.unlock(l) 
        else
            res = get_data(cate, page)
            response_text = String(res.body)
            msg = JSON.parse(response_text)
            #write a to a json file
            # println(filepath * filename)
            open(filepath * filename, "w") do f
                JSON.print(f, msg)
            end
            # println("Page ", page, " done")
            res = nothing #clear the memory
            # if page == 2 
            #     println("Test Run Ended")
            #     break
            # end
            Threads.atomic_add!(jj, 1)
            Threads.lock(l)
            ProgressMeter.update!(p, jj[])
            Threads.unlock(l) 
        end
 
    end
    println("Scraping process ended")
    println("#"^20)
end


#test run to get the total number of pages first
res = get_data("materials", 1)
@show n::Int64 = parse(Int64,Dict(res.headers)["X-Total-Count"])
fullpath = joinpath(@__DIR__, "rawdata_$n/")
println("Current fullpath: $fullpath")
try
    mkdir(fullpath)
catch
    println("Path:$fullpath is already exist")
    println("Please proceed with care")
end
response_text = String(res.body)
msg = JSON.parse(response_text)
println("Start scraping")
scrapeit(all=true, total_pages = n , path = fullpath)
# scrapeit()
# df = DataFrame(msg)
##########
# 06 Aug 
# X-Total-Count: 147130
# X-Total-Pages: 1472

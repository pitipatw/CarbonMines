using HTTP, JSON, DataFrames
using ProgressMeter
#GOAL
#at the first loop, get the total number of pages
#get that by res["X-Total-Pages"]
#Each page will have 100 items, therefore loop from 1 to res["X-Total-Pages"]
#at each loop, get the data from the page
#save the data to a json file separate by the filename 
#filename = "ECS" * string(i) * ".json"

include("key.jl")

function get_data(cate::String, page::Int64
    ; token::String=token, mode::Int64=0)
    if mode == 0
        res = HTTP.request("GET",
            "https://buildingtransparency.org/api/$cate/?page_number=$page", #materials?page_number=2",
            ["Authorization" => "Bearer " * "$token"]
        )
    else
        #different categories, or do something else
        println("Mode not found")
        res = 0.0
    end
    return res
end


#test run to get the total number of pages first
res = get_data("materials", 1)
response_text = String(res.body)
msg = JSON.parse(response_text)
df = DataFrame(msg)
##########
# 06 Aug 
# X-Total-Count: 147130
# X-Total-Pages: 1472

function scrapeit(;all::Bool=false, total_pages::Int64=5)
    cate = "materials"
    page = 1 #start from page 1

    filepath = joinpath(@__DIR__, "rawdata/")

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
    update!(p,1)
    jj = Threads.Atomic{Int}(0)
    l = Threads.SpinLock()
    Threads.@threads for page = 1:total_pages

        res = get_data(cate, page)
        # if page == 1 & total_pages != 10 #first run
        #     total_pages = parse(Int64, (res["X-Total-Pages"]))
        #     println("Scraping process started")
        #     println("There are :", total_pages, " pages")
        # end

        response_text = String(res.body)

        #get number to 0000 format for filename
        spg = "0"^(4 - length(string(page))) * string(page)
        filename = "pg" * string(spg) * ".json"

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
        update!(p, jj[])
        Threads.unlock(l)  
    end
    println("Scraping process ended")
    println("#"^20)
end
@time scrapeit()

@time scrapeit(all=true)

#Data visualization
using Makie, GLMakie
using CSV, DataFrames

#load file
df = CSV.read("df_f.csv", DataFrame)
#get all countries names
countries = unique(df[!, "country"])




#tidy up countries
include("map.jl")
country_mapped = Vector{String}(undef, size(df)[1])
for i in eachindex(df[!,"country"])
    country_mapped[i] = country_maps[df[i,"country"]]
end

df[!,"country_map"] = country_mapped
countries = unique(df[!,"country_map"])



#remove row that has 0 for both fc and gwp
df = df[df[!,"fc"].!=0, :]
df = df[df[!,"gwp"].!=0, :]


#check countries that only have 0s
rev_countries = Vector{String}()
for i in eachindex(countries)
    if sum(df[df[!,"country_map"].==countries[i], :][!, "gwp"]) == 0 
        println(countries[i])
        push!(rev_countries, countries[i])
    end
end


#count how many data points for each country
c_count = Vector{Int}(undef, size(countries)[1])
for i in eachindex(countries)
    c_count[i] = size(df[df[!,"country_map"].==countries[i], :])[1]
end
c_count
#sort countries by number of data points


axs = Vector{Axis}(undef, size(countries)[1])
f_all = Figure(resolution = (2000,3000))
count = 0
cind = 0
for i in eachindex(countries)
    cind += 1 
    if false #countries[i] == "US"
        continue
    elseif countries[i] in rev_countries
        continue
    else
        count +=1
        r = div(count-1,5)+1
        c = mod(count-1,5)+1
        # println(count, "=>",r,c)
        title = countries[i]
        #create axis for that country
        axs[count] = Axis(f_all[r,c], title = title*" ("*string(c_count[cind])*")")
        xlims!(axs[count], 0,100)
        ylims!(axs[count], 0,0.5)
        scatter!(axs[count], df[df[!,"country_map"].==title,"fc"], df[df[!,"country_map"].==title, :][!, "gwp"], 
        markersize = 10, color = :blue)
    end
end
f_all

save("fig3.png", f_all)
CSV.write("Ec3.csv", df)


plotacountry(df,"New Zealand")
f_us = plotacountry(df,"United States")
save("fig_us.png", f_us)
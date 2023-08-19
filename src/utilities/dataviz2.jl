#Data visualization
using Makie, GLMakie, GeoMakie
using CSV, DataFrames

#load file
df = CSV.read("compact.csv", DataFrame)
#get all countries names
countries = unique(df[!, "country"])

#tidy up countries
include("map2.jl")
include("utilities.jl")
country_mapped = Vector{String}(undef, size(df)[1])
for i in eachindex(df[!,"country"])
    country_mapped[i] = country_maps[df[i,"country"]]
end

df[!,"country_map"] = country_mapped
countries = unique(df[!,"country_map"])


df = df[df[!,"str28d"].!=0, :]
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
global count = 0
global cind = 0
kwargs = (;xminorticksvisible = true, yminorticksvisible = true, xminorgridvisible = true, yminorgridvisible = true)
for i in eachindex(countries)
    global cind += 1 
    if false #countries[i] == "US"
        continue
    elseif countries[i] in rev_countries
        continue
    else
        global count +=1
        r = div(count-1,8)+1
        c = mod(count-1,8)+1
        # println(count, "=>",r,c)
        title = countries[i]
        #create axis for that country
        axs[count] = Axis(f_all[r,c], title = title*" ("*string(c_count[cind])*")"; xminorticks = IntervalsBetween(5), yminorticks = IntervalsBetween(5), kwargs...)
        xlims!(axs[count], 0,100)
        ylims!(axs[count], 0,1.0)
        scatter!(axs[count], df[df[!,"country_map"].==title,"str28d"], df[df[!,"country_map"].==title, :][!, "gwp"], 
        markersize = 10, color = df[df[!,"country_map"].==title, :][!, "gwp"])
    end
end
f_all

save("fig5.png", f_all)
CSV.write("Ec3.csv", df)



f_map_all = Figure(resolution = (720,1080))
kwargs = (;xminorticksvisible = true, yminorticksvisible = true, xminorgridvisible = true, yminorgridvisible = true)
colors = 1:size(countries)[1]
colors = colors./maximum(colors)

ga = GeoAxis(
    f_map_all[1, 1]; # any cell of the figure's layout
    lonlims = (-125, -65),#: The limits for longitude (x-axis). For automatic determination, pass lonlims=automatic.
    latlims = (-10, 60),
    coastlines = true # plot coastlines from Natural Earth, as a reference.
)

scatter!(ga, df[!, "long"], df[!, "lat"],markersize = 5, color = df[!, "gwp"])

f_map_all
save("fig_map_us.png", f_map_all)

plotacountry(df,"United States")
f_us = plotacountry(df,"United States")
save("fig_us_lat.png", f_us)
#Data visualization
using Makie, GLMakie, GeoMakie
using CSV, DataFrames
using kjlMakie
using GLM
using LaTeXStrings

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



function plot_by_continent(df::DataFrame, continent::String)

    set_theme!(kjl_light)
    df = DataFrame(CSV.File("df_ready.csv"))
    a_continent = df[df[!, "continent"] .== continent, :]


#remove gwp that's more than 1
deleteat!(a_continent, a_continent[!, "gwp_values"].>1)
deleteat!(a_continent, a_continent[!, "fc_prime_MPa"] .< 28 )
deleteat!(a_continent, a_continent[!, "fc_prime_MPa"] .> 55 )




model = DataFrame(x = a_continent[!,"fc_prime_MPa"], y=  a_continent[!, "gwp_values"])


    model1 = lm(@formula(y ~ x), model)
function1 = x -> coef(model1)[2]*x + coef(model1)[1]




f1 = Figure( resolution = (1280,720))
ax1 = f1[1,1] = Axis(f1,
    # title
    title = 
    "GWP vs fc' [$continent]",
    titlegap = 36, titlesize = 24,
    # x-axis
    # xgridvisible = false,
    xgridcolor = :lightgray, xgridwidth = 2,
    xlabel = "fc' [MPa]" , xlabelsize = 28,
    xticklabelsize = 24, xticks = LinearTicks(8),
    # y-axis
    # ygridvisible = false,
    ygridcolor = :lightgray, ygridwidth = 2,
    ylabel = "GWP [kgCO2e/kg]",
    ylabelsize = 24, #ytickformat = "{:d}",
    yticklabelsize = 24, yticks = LinearTicks(7),

    limits = (25, 60,0,0.3)
)

scatter!(ax1, a_continent[!, "fc_prime_MPa"], a_continent[!, "gwp_values"], color = :blue, markersize = 10)
lines!(ax1 , 25:1:60, function1.(25:1:60))
text!( 40,0.25,
  text = latexstring(
    "y = $(round(coef(model1)[2], digits = 4))x + $(round(coef(model1)[1], digits = 2))"
  ),
  fontsize = 20
)
    return f1
end

f_asia = plot_by_continent(df_single,"Asia")
f_north_america = plot_by_continent(df_single, "North America")
f_europe = plot_by_continent(df_single, "Europe")
f_australia = plot_by_continent(df_single, "Australia")
f_middle_east = plot_by_continent(df_single, "Middle East")

save("f_asia.png", f_asia)
save("f_north_america.png", f_north_america)
save("f_europe.png", f_europe)
save("f_australia.png", f_australia)
save("f_middle_east.png", f_middle_east)

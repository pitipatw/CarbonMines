using Makie, GLMakie, GeoMakie, CairoMakie
using CSV, DataFrames, JSON

"""
Figure 1: Introduction plot (OurWorld dataset)
plot the timeline of the carbon emission in the industry
"""
#load the dataset
df1 = CSV.read("C://Users//pitipatw//Dropbox (MIT)//dev//CarbonMines//Dataset 1 (OurWorldData).csv", DataFrame)
sort!(df1, [:Entity, :Year])

countries = unique(df1[!, :Entity])

skipcountries = ["Asia", "Asia (excl. China and India)", "Europe", "Europe (excl. EU-27)", "Europe (excl. EU-28)", "European Union (27)", "European Union (28)", "High-income countries", "Low-income countries", "Lower-middle-income countries", "North America", "North America (excl. USA)", "Upper-middle-income countries"]
nskip = length(skipcountries)
skipcheck = skipcountries
f1 = Figure( size = (2000,1000))
ax1 = Axis(f1[1,1], title = "History of CO2 emission around the world", xlabel = "Year", ylabel = "Annual CO2 emission from cement",)
ax2 = Axis(f1[1,2], title = "History of CO2 emission around the world", xlabel = "Year", ylabel = "Annual CO2 emission from cement",yscale = log10, limits =(nothing, nothing, 1, 1e10))
for ci in eachindex(countries)
    country = countries[ci] 
    if country ∈ skipcountries 
        nskip -= 1
        continue
    end

    df1_country = df1[ df1.Entity .== countries[ci], :]
    lines!(ax1, df1_country.Year, 1 .+ df1_country[!,"Annual CO2 emissions from cement"], label = countries[ci])
    lines!(ax2, df1_country.Year, 1 .+ df1_country[!,"Annual CO2 emissions from cement"], label = countries[ci])
end

Legend(f1[2,1], ax1, orientation = :horizontal, tellwidth = false, tellheight = true, nbanks = 5)
# Legend(f1[2,2], ax2)


f1
save( "f1.png", f1)
"""
Figure 2: Map plot. (EC3 data)
Plot the overall embodied carbon intensity throughout the world.
Map of the world with gradients in the country
"""
# load EC3 data.
df2 = CSV.read("C://Users//pitipatw//Dropbox (MIT)//dev//CarbonMines//Dataset 2 (EC3).csv", DataFrame)
df2.lat = collect(df2.lat)
df2.long = collect(df2.long)
df2.gwp_values = collect(df2.gwp_values)
df2.fc_prime_MPa = collect(df2.fc_prime_MPa)

#callout lat long = (0,0)
df2_nozerolatlong = df2[ df2.lat .!= 0 .&& df2.long .!= 0,:]
f2 = Figure(size = (1000,1000))
ax2_geo = GeoAxis(f2[1,1])
lines!(ax2_geo, GeoMakie.coastlines())

scatter!(ax2_geo, df2_nozerolatlong.long, df2_nozerolatlong.lat, color = df2_nozerolatlong.gwp_values, markersize = df2_nozerolatlong.fc_prime_MPa/5)


f2

save("f2.png", f2)

"""
#Figure 3: Map plot (US)
"""


#load Broyels dataset
#plot the same thing, but only with the US scale. 
# load EC3 data.
df3 = CSV.read("C://Users//pitipatw//Dropbox (MIT)//dev//CarbonMines//Dataset 3 (Broyles).csv", DataFrame)
#find long lat from the zipcode
df3[!,:zip] = df3[!, "Plant Location - Zip"]
usstatelines = JSON.parsefile("src//us-states.json")
usstatelines = GeoJSON.read("src//us-states.json")

long = Vector{Float64}()
lat = Vector{Float64}()
notfound = Vector{Int64}()
for i in 1:size(df3)[1]
    zip = df3[i, :zip]
    # @show i, zip, ZIPCODES[ZIPCODES.zip .== zip,:longitude], ZIPCODES[ZIPCODES.zip .== zip,:latitude]
    longi = ZIPCODES[ZIPCODES.zip .== zip,:longitude]
    lati  = ZIPCODES[ZIPCODES.zip .== zip,:latitude]
    if length(longi) == 0 
        if zip ∉ notfound
            push!(notfound, zip)
            println(zip)
        end
        push!(long, 0.0)
        push!(lat,0.0)
    else
        push!(long, ZIPCODES[ZIPCODES.zip .== zip,:longitude][1])
        push!(lat, ZIPCODES[ZIPCODES.zip .== zip,:latitude][1])
    end
end


df3[!, :long] = long
df3[!, :lat] = lat


df3[!,"A1-A3 Global Warming Potential (kg CO2-eq)"] = collect(df3[!,"A1-A3 Global Warming Potential (kg CO2-eq)"])
df3[!, "Concrete Compressive Strength (MPa)"] = collect(df3[!, "Concrete Compressive Strength (MPa)"])

f3 = Figure(size = (1000,1000))
ax3_geo = GeoAxis(f3[1,1])
ax3_geo_us = GeoAxis(f3[2,1], limits = ((-130,-60),(20,50)),  dest = "+proj=merc")

lines!(ax3_geo, GeoMakie.coastlines())
# lines!(ax3_geo_us, GeoMakie.coastlines())
poly!(ax3_geo_us, usstatelines; strokewidth = 0.7, color=:gold, rasterize = 5)


scatter!(ax3_geo, df3.long, df3.lat, color = df3[!,"A1-A3 Global Warming Potential (kg CO2-eq)"], markersize = df3[!, "Concrete Compressive Strength (MPa)"]/5)
scatter!(ax3_geo_us, df3.long, df3.lat, color = df3[!,"A1-A3 Global Warming Potential (kg CO2-eq)"], markersize = df3[!, "Concrete Compressive Strength (MPa)"]/10)


f3


save("f3.png", f3)


"""
Figure 4 
"""

#call only the dataset of each region -> use that to calculate the embodied carbon of the example building using that region's datset 
#Show the value.
using GLM

#building footprint 
f4 = Figure(size = (1000,1000))

#pick a city,


df3_picked1 = df3[df3[!,"Plant Location - State"] .== "CA",:]
df3_picked2 = df3[df3[!,"Plant Location - State"] .== "MA",:]

fittedcurve1 = lm(df3_picked1[!,""])
fittedcurve2 = 


#get a dataframe of the numbers 
#Then, fit the curve as carbonmap equation
carboneq(x) = x^2
volumns = [10, 20, 10, 30]
fc′s = [28, 35, 45, 60]

carbon =  sum(volumns .* carboneq.(fc′s))



#now, find a way to display it. 
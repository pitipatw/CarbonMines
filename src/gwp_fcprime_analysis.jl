"""
working with df_single dataframe
"""

using PlotlyJS
using Makie, GLMakie
using DataFrames, CSV

include("continent.jl")
#load the file into a dataframe
df_single = DataFrame(CSV.File("df_single.csv"))
#check if we have all of the columns we need
colnames = sort(names(df_single))

#requires columns to be presented
reqcols = ["concrete_compressive_strength_28d",
    "concrete_compressive_strength_other_d",
    "gwp_per_category_declared_unit",
    "gwp_per_kg",
    "declared_unit",
];

#check if those columns actually exist
for i in reqcols
    if i in colnames
    else
        println("missing $i")
    end
end

fc′_values = Vector{Float64}(undef, size(df_single, 1))
fc′_units = Vector{String}(undef, size(df_single, 1))
for i in 1:size(df_single, 1)
    # println(df_single[i, "concrete_compressive_strength_28d"])
    # println(i)
    if ismissing(df_single[i, "concrete_compressive_strength_28d"])
        # println(i)
        # println(fc′_values[i])
        # println(fc′_units[i])

        fc′_values[i] = 0.0
        fc′_units[i] = "-"

    else

        global stringi = lowercase(df_single[i, "concrete_compressive_strength_28d"])
        #this might be due to no space input (e.g. 75MPa instead of 75 MPa)
        #at this stage, only error on MPa, so let's find M in MPa
        m_loc = findfirst("mpa", stringi)
        p_loc = findfirst("psi", stringi)
        if m_loc !== nothing
            #this is MPa, so let's convert it to MPa
            fc′_values[i] = parse(Float64, first(stringi, m_loc[1] - 1))
            fc′_units[i] = "MPa"

        elseif p_loc !== nothing
            #this is not MPa, so it's probably psi
            fc′_values[i] = parse(Float64, first(stringi, p_loc[1] - 1))
            fc′_units[i] = "psi"
        else
            #there is n / mm2 which is MPa
            n_mm2 = findfirst("n / mm2", stringi)
            if n_mm2 !== nothing
                fc′_values[i] = parse(Float64, first(stringi, n_mm2[1] - 1))
                fc′_units[i] = "MPa"

            else
                println(i)
                println(stringi)
            end
        end
        # in case psi is the problem
    end
end


#convert psi to MPa
fc′_values_MPa = Vector{Float64}(undef, size(df_single, 1))
# 1 psi =
psi_to_mpa = 0.00689476 #MPa
for i in 1:size(df_single, 1)
    if fc′_units[i] == "psi"
        fc′_values_MPa[i] = fc′_values[i] * psi_to_mpa
    elseif fc′_units[i] == "MPa"
        fc′_values_MPa[i] = fc′_values[i]
    elseif fc′_units[i] == "-"
        fc′_values_MPa[i] = 0.0
    else
        println("error")
    end
end

df_single[!, "fc_prime_MPa"] = fc′_values_MPa

#do the same thing with gwp_per_kg
gwp_values = Vector{Float64}(undef, size(df_single, 1))
gwp_units = Vector{String}(undef, size(df_single, 1))
for i in 1:size(df_single, 1)
    # println(df_single[i, "concrete_compressive_strength_28d"])
    # println(i)
    if ismissing(df_single[i, "gwp_per_kg"])
        gwp_values[i] = 0.0
        gwp_units[i] = "Missing"
    else
        global stringi = lowercase(df_single[i, "gwp_per_kg"])

        #this might be due to no space input (e.g. 75MPa instead of 75 MPa)
        #at this stage, only error on MPa, so let's find M in MPa
        unit_loc = findfirst("kgco2e", stringi)
        # p_loc = findfirst("psi", stringi)
        if unit_loc !== nothing
            #this is MPa, so let's convert it to MPa
            gwp_values[i] = parse(Float64, first(stringi, unit_loc[1] - 1))
            gwp_units[i] = "kgCO2e"
        else
            println(i)
            println(stringi)
        end
        # in case psi is the problem
    end
end

df_single[!, "gwp_values"] = gwp_values
df_single[!, "gwp_units"] = gwp_units
df_single[!, "gwp_per_fcprime_kg"] = df_single[!, "gwp_values"] ./ df_single[!, "fc_prime_MPa"]


#convert every fc into MPa
for i = 1:size(df_single, 1)
    val = df_single[i, "gwp_per_fcprime_kg"]
    if !(typeof(val) <: Number)
        df_single[i, "gwp_per_fcprime_kg"] = 0.0
    end
end

#remove fcprime that's lower than 28 MPa let's do this when plotting

continent = Vector{String}(undef, size(df_single, 1))
for i = 1:size(df_single, 1)
    c = df_single[i, "country"]
    if c in europe #european_country_abbreviations
        continent[i] = "Europe"
    elseif c in north_america
        continent[i] = "North America"
    elseif c in asia
        continent[i] = "Asia"
    elseif c in australia
        continent[i] = "Australia"
    elseif c in middle_east
        continent[i] = "Middle East"
    elseif c in south_america
        continent[i] = "South America"
    elseif c == "Missing"
        continent[i] = "Missing"
    else
        println(df_single[i, "country"])
        println(df_single[i, "address"])
        println(df_single[i, "name"])
    end
end

df_single[!, "continent"] = continent


CSV.write("df_ready.csv", df_single) ;#174 columns




# for i = 1:size(df_single, 1)
#     n = lowercase(df_single[i, "name"])
#     if occursin("steel", n)
#         # println(n)
#     elseif occursin("sheet", n)
#         # println(n)
#     elseif occursin("concrete", n)
#         # println(n)
#     elseif occursin("mix", n)
#         # elseif occursin("metal", n)
#         # elseif occursin("utp", n)
#         # elseif occursin("pvc", n)
#         # elseif occursin("genspeed", n)
#     else
#         println(n)
#     end
# end
"""
working with df_single dataframe
"""

using PlotlyJS
using DataFrames, CSV
#load the file into a dataframe
df_single = CSV.read("df_single.csv", DataFrame)
#check if we have all of the columns we need
colnames = sort(names(df_single))

reqcols = ["concrete_compressive_strength_28d",
    "concrete_compressive_strength_other_d",
    "gwp_per_category_declared_unit",
    "gwp_per_kg",
    "declared_unit",
];

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
        fc′_values[i] = 0.0
        fc′_units[i] = missing
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
    elseif ismissing(fc′_units[i])
        fc′_values_MPa[i] = 0.0
    else
        println("error")
    end
end

df_single[!,"fc_prime_MPa"] = fc′_values_MPa

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
df_single[!, "gwp_per_fcprime_kg"] = df_single[!, "gwp_per_kg"] ./ df_single[!, "fc_prime_MPa"]


#convert every fc into MPa
df_single[!, ""]

#remove fcprime that's lower than 28 MPa

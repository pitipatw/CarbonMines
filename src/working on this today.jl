using Makie, GLMakie
using CSV, DataFrames
using kjlMakie
using GLM
using LaTeXStrings
using LsqFit
#plot by USA and Europe
set_theme!(kjl_light)
include("utilities\\checkpoints.jl")

df_ready = DataFrame(CSV.File("df_ready2.csv"))


plants = df_ready[!, "carbon_intensity"]


units = []
what = []
vals = Vector{Float64}(undef, size(plants)[1])
for i in 1:1000 #eachindex(collect(plants))
    tmp = plants[i]

    blank_pos = findfirst(" ", tmp)
    if blank_pos === nothing
        # println(tmp)
        # if tmp ∉ what
        #     push!(what, tmp)
        # end
        vals[i] = 0.0
    else
        unit = last(tmp,length(tmp) - blank_pos[1])
        if unit == "lbCO2e/MWh"
            vals[i] = 0.454*parse(Float64, first(tmp, blank_pos[1]-1))
        else
            vals[i] = parse(Float64, first(tmp, blank_pos[1]-1))
        end
        
    end
end

df_ready[!,"intensity"] = vals
USA = df_ready[df_ready[!, "country"] .== "US", :]
Europe = df_ready[df_ready[!,"continent"] .== "Europe",:]

#remove gwp that's more than 1
deleteat!(USA, USA[!, "gwp_values"].>1)
deleteat!(USA, USA[!, "fc_prime_MPa"] .< 28 )
deleteat!(USA, USA[!, "fc_prime_MPa"] .> 55 )
117406 - 117382

#remove gwp that's more than 1
deleteat!(Europe, Europe[!, "gwp_values"].>1)
deleteat!(Europe, Europe[!, "fc_prime_MPa"] .< 28 )
deleteat!(Europe, Europe[!, "fc_prime_MPa"] .> 55 )

USA[!, "gwp_per_fc′"] = USA[!,"gwp_values"]./USA[!,"fc_prime_MPa"]
Europe[!, "gwp_per_fc′"] = Europe[!,"gwp_values"]./Europe[!,"fc_prime_MPa"]


USAmodel = DataFrame(x = USA[!,"fc_prime_MPa"], y=  USA[!, "gwp_values"])
Europemodel = DataFrame( x = Europe[!, "fc_prime_MPa"], y = Europe[!, "gwp_values"])


"""
Polynomial model, in the form of 
a0 + a1x^1 + a2x^2
"""
function model_poly(x,a)
    return a[1] .+ a[2].*x .+ a[3].*x.^2
end

a0 = [0.5, 0.5, 0.5]
fit = curve_fit(model_poly, USA[!,"fc_prime_MPa"], USA[!, "gwp_values"], a0)


model1 = lm(@formula(y ~ x), USAmodel)
model2 = lm(@formula(y ~ x), Europemodel)
function1 = x -> coef(model1)[2]*x + coef(model1)[1]
function2 = x -> coef(model2)[2]*x + coef(model2)[1]



f1 = Figure( resolution = (1280,1000))
ax1 =Axis(f1[1,1],
    # title
    title = 
    "GWP vs fc' [USA]",
    # titlegap = 36, titlesize = 24,
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

    # # ygridcolor = :lightgray, ygridwidth = 2,
    # zlabel = "Intensity [kgCO2e/KWh]",
    # zlabelsize = 24, #ytickformat = "{:d}",
    # zticklabelsize = 24, #yticks = LinearTicks(7),

    # limits = (25, 60,0,0.7)
)

scatter!(ax1, USA[!, "fc_prime_MPa"], USA[!, "gwp_values"],color = USA[!, "intensity"], markersize = 10)
scatter!(ax1, USA[!, "fc_prime_MPa"], model_poly(USA[!, "fc_prime_MPa"], fit.param), color = :red, linewidth = 3)
# savepng("plot-with-intensity", f1)

f2 = Figure( resolution = (1280,1000))
ax2 =Axis3(f2[1,1],
    # title
    title = 
    "GWP vs fc' [Europe]",
    # titlegap = 36, titlesize = 24,
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

    # ygridcolor = :lightgray, ygridwidth = 2,
    zlabel = "Intensity [kgCO2e/KWh]",
    zlabelsize = 24, #ytickformat = "{:d}",
    zticklabelsize = 24, #yticks = LinearTicks(7),

    # limits = (25, 60,0,0.7)
)

scatter!(ax2, Europe[!, "fc_prime_MPa"], Europe[!, "gwp_values"], Europe[!, "intensity"],color = Europe[!, "intensity"], markersize = 10)
savepng("plot-with-intensity_EU", f2)
using Makie, GLMakie
using CSV, DataFrames
using kjlMakie
using GLM
using LaTeXStrings
#plot by USA and Europe
set_theme!(kjl_light)


df_single = DataFrame(CSV.File("df_ready.csv"))
USA = df_single[df_single[!, "country"] .== "US", :]
Europe = df_single[df_single[!,"continent"] .== "Europe",:]


#remove gwp that's more than 1
deleteat!(USA, USA[!, "gwp_values"].>1)
deleteat!(USA, USA[!, "fc_prime_MPa"] .< 28 )
deleteat!(USA, USA[!, "fc_prime_MPa"] .> 55 )
117406 - 117382

#remove gwp that's more than 1
deleteat!(Europe, Europe[!, "gwp_values"].>1)
deleteat!(Europe, Europe[!, "fc_prime_MPa"] .< 28 )
deleteat!(Europe, Europe[!, "fc_prime_MPa"] .> 55 )

USAmodel = DataFrame(x = USA[!,"fc_prime_MPa"], y=  USA[!, "gwp_values"])
Europemodel = DataFrame( x = Europe[!, "fc_prime_MPa"], y = Europe[!, "gwp_values"])


model1 = lm(@formula(y ~ x), USAmodel)
model2 = lm(@formula(y ~ x), Europemodel)
function1 = x -> coef(model1)[2]*x + coef(model1)[1]
function2 = x -> coef(model2)[2]*x + coef(model2)[1]



f1 = Figure( resolution = (1280,720))
ax1 = f1[1,1] = Axis(f1,
    # title
    title = 
    "GWP vs fc' [USA]",
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

    limits = (25, 60,0,0.7)
)

scatter!(ax1, USA[!, "fc_prime_MPa"], USA[!, "gwp_values"], color = :green, markersize = 10)
lines!(ax1 , 25:1:60, function1.(25:1:60))
text!( 50,0.5,
  text = latexstring(
    "y = $(round(coef(model1)[2], digits = 4))x + $(round(coef(model1)[1], digits = 2))"
  ),
  fontsize = 20
)


f2 = Figure( resolution = (1280,720))
ax2 = f2[1,1] = Axis(f2,
    # title
    title = 
    "GWP vs fc' [Europe]",
    titlegap = 36, titlesize = 28,
    # x-axis
    #xgridcolor = :darkgray, #xgridwidth = 2,
    xlabel = "fc' [MPa]" , xlabelsize = 24,
    xticklabelsize = 24, xticks = LinearTicks(10),
    # y-axis
   # ygridcolor = :darkgray, #ygridwidth = 2,
    ylabel = "GWP [kgCO2e/kg]",
    ylabelsize = 24, #ytickformat = "{:d}",
    yticklabelsize = 24, yticks = LinearTicks(7),

    limits = (25,61,0,0.7)
)
scatter!(ax2, Europe[!, "fc_prime_MPa"], Europe[!, "gwp_values"], color = :blue)

lines!(ax2 , 25:1:60, function2.(25:1:60))
text!( 50,0.5,
  text = latexstring(
    "y = $(round(coef(model2)[2], digits = 4))x + $(round(coef(model2)[1], digits = 2))"
  ),
  fontsize = 20
)

f2
f1

save("CISBAT1.png" , f1)
save("CISBAT2.png" , f2)


f21 = Figure( resolution = (1280,720))
ax21 = f21[1,1] = Axis(f21,
    # title
    title = 
    "GWP vs fc' [Europe]",
    titlegap = 36, titlesize = 28,
    # x-axis
    #xgridcolor = :darkgray, #xgridwidth = 2,
    xlabel = "fc' [MPa]" , xlabelsize = 24,
    xticklabelsize = 24, xticks = LinearTicks(10),
    # y-axis
   # ygridcolor = :darkgray, #ygridwidth = 2,
    ylabel = "GWP [kgCO2e/kg]",
    ylabelsize = 24, #ytickformat = "{:d}",
    yticklabelsize = 24, yticks = LinearTicks(7),

    limits = (25,61,0,0.3)
)
scatter!(ax21, Europe[!, "fc_prime_MPa"], Europe[!, "gwp_values"], color = :blue)

lines!(ax21 , 25:1:60, function2.(25:1:60))
text!( 50,0.2,
  text = latexstring(
    "y = $(round(coef(model2)[2], digits = 4))x + $(round(coef(model2)[1], digits = 2))"
  ),
  fontsize = 20
)

save("CISBAT2-2.png", f21)
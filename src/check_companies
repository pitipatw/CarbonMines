# include("main.jl")
# include("gwp_fcprime_analysis.jl")
#we are working with df_single 
#now we know the plot, we can see each compay (only 200 companies) 
using Makie
using GLMakie
using Observables
using CSV, DataFrames


df_single = DataFrame(CSV.File("df_ready2.csv"))
Makie.inline!(false)
companies = sort(unique(df_single[!,"owned_by"]))

f1 = Figure(resolution = (1920,1600))
menu = Menu(f1, options = companies, default = companies[1])

# funcs = [sqrt, x->x^2, sin, cos]

# menu2 = Menu(fig,
#     options = zip(["Square Root", "Square", "Sine", "Cosine"], funcs),
#     default = "Square")

f1[1, 1] = vgrid!(
    Label(f1, "Owned By", width = nothing),
    menu,
    tellheight = false, width = 200)


ax1 = f1[1,2] = Axis(f1,
    # title
    title = 
    "GWP vs fc'",
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

    limits = (20, 65,0,0.7)
)
#plot everything as grey by default

xs = Observable(df_single[!,"fc_prime_MPa"])
ys = Observable(df_single[!,"gwp_values"])

scatter!(ax1, df_single[!,"fc_prime_MPa"], df_single[!,"gwp_values"] , color = :grey, markersize = 10)
scatter!(ax1, xs,ys , color = :green, markersize = 20)

# # r = lift(plot_company)
# # cb = Colorbar(fig[1, 3], scat)
on(menu.selection) do s
    # println(typeof(s))
    bits = df_single[!,"owned_by"] .== s
    # println("bits", typeof(bits))
    # println("xx",typeof(df_single[bits, "gwp_values"]))
    xs.val = df_single[bits, "fc_prime_MPa"]
    ys[] = df_single[bits, "gwp_values"]
end

# # end
notify(menu.selection)
menu.is_open = true
f1


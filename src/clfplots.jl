using Makie, GLMakie
using CSV, DataFrames
using kjlMakie
using GLM
using LaTeXStrings
using ColorSchemes
#plot by USA and Europe
set_theme!(kjl_light)

include("utilities\\checkpoints.jl")

df_CLF = DataFrame(CSV.File("csv_files\\CLF_dataset.csv"))

cols = ["17.2", "20.7", "27.6", "34.5", "41.4", "55.1"]
colss = parse.(Float64,cols)

#scale and map to 0-256
# step = 256/length(colss)
# color_map = 0:step:256
# color_plot = ColorSchemes.viridis.colors[color_map]

df = DataFrame()
df = df_CLF[!,cols]./2400
df[!, "location"] = df_CLF[!,"Detailed Location"]
println(df)

dfs= Vector{DataFrame}()
for i in 1:size(df)[1]
    model = DataFrame(x = colss, y = collect(df[i,cols]))
    push!(dfs, model)
end

models = []
funcs = []
for j in 1:size(df)[1]
    modelj = lm(@formula(y ~ x), dfs[j])
    functionj = x -> coef(modelj)[2]*x + coef(modelj)[1]

    push!(models, modelj)
    push!(funcs, functionj)
end

df2 = copy(df)
for i in eachindex(cols)
    fc′ = colss[i]
    
    df2[:,cols[i]] = df2[:,cols[i]]/fc′
end


f1 = Figure( resolution = (1280,720))
f2 = Figure( resolution = (1280,720))

ax1 = f1[1,1] = Axis(f1,
    # title
    title = 
    "GWP vs fc' [CLF]",
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

    limits = (15, 60,0.08,0.22)
)

ax2 = f2[1,1] = Axis(f2,
    # title
    title = 
    "GWP vs fc' [CLF]",
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

    limits = (15, 60,0.08,0.22)
)



txt =[ latexstring(
    "y = $(round(coef(models[j])[2], digits = 4))x + $(round(coef(models[j])[1], digits = 2))"
  ) for j in 1:size(df)[1]
]

sca = []
for i in 1:size(df)[1]
    s1 = scatter!(ax1, colss, collect(df[i,cols]), markersize = 10)
    
    xs = 16:1:58
    lines!(ax2 , xs, funcs[i].(xs))
    text!( 18, 0.13+i/150, text = txt[i],fontsize = 20)
    push!(sca, s1)

    # s2 = scatter!(ax3, colss, collect(df2[i,cols]), markersize = 10)


end

Legend(f1[1,2],sca, df[!, "location"])



dfs2= Vector{DataFrame}()
for i in 1:size(df)[1]
    model = DataFrame(x = colss, y = collect(df2[i,cols]))
    push!(dfs2, model)
end

models = []
funcs = []
for j in 1:size(df)[1]
    modelj = lm(@formula(y ~ x), dfs2[j])
    functionj = x -> coef(modelj)[2]*x + coef(modelj)[1]

    push!(models, modelj)
    push!(funcs, functionj)
end




f3 = Figure( resolution = (1280,720))
ax3 = f3[1,1] = Axis(f3,
    # title
    title = 
    "GWP per fc′ vs fc' [CLF]",
    titlegap = 36, titlesize = 24,
    # x-axis
    # xgridvisible = false,
    xgridcolor = :lightgray, xgridwidth = 2,
    xlabel = "fc' [MPa]" , xlabelsize = 28,
    xticklabelsize = 24, xticks = LinearTicks(8),
    # y-axis
    # ygridvisible = false,
    ygridcolor = :lightgray, ygridwidth = 2,
    ylabel = "GWP [kgCO2/MPa]",
    ylabelsize = 24, #ytickformat = "{:d}",
    yticklabelsize = 24, yticks = LinearTicks(7),

    limits = (15, 60,0.0019,0.0066)
)

txt =[ latexstring(
    "y = $(round(coef(models[j])[2], digits = 6))x + $(round(coef(models[j])[1], digits = 2))"
  ) for j in 1:size(df)[1]
]

sca = []
for i in 1:size(df)[1]
    s1 = scatter!(ax3, colss, collect(df2[i,cols]), markersize = 10)
    
    xs = 16:1:58
    lines!(ax3 , xs, funcs[i].(xs))
    text!( 18, 0.002+i/5000, text = txt[i],fontsize = 20)
    push!(sca, s1)

    # s2 = scatter!(ax3, colss, collect(df2[i,cols]), markersize = 10)


end

f1
f2
f3


savepng("CLF_scatter",f1 )
savepng("CLF_lines",f2)
savepng("CLF_ratio",f3 )







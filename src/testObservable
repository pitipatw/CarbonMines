using Makie, GLMakie
using DataFrames

df = DataFrame(
    x = [1. ,2. ,3.],
    y =[200., 400., 500.],
    z = [:red, :blue, :green]
)

ys = Observable([1.,2.,3.])
function getindex(df::DataFrame,io::Observable{T}, x::String) where {T}
    return df[io.val, x]
end
f1 = Figure(resolution = (800,800)) 
menu = Menu(f1, options = vcat(1,2,3), default = 1)

# funcs = [sqrt, x->x^2, sin, cos]

# menu2 = Menu(fig,
#     options = zip(["Square Root", "Square", "Sine", "Cosine"], funcs),
#     default = "Square")

f1[1, 1] = vgrid!(
    Label(f1, "Owned By", width = nothing),
    menu,
    tellheight = false, width = 200)
ax1 =Axis(f1[1,2])
scatter!(ax1, df[!,"x"], ys, markersize = 20)

on(menu.selection) do s
    ys[] = df[!,"y"].-10*s
end
notify(menu.selection)

f1
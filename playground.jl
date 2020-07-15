using Pkg
cd(@__DIR__)
pkg"activate ."
using BenchmarkTools

smaller(a::T, b::T) where {T<:Integer} = a < b ? a : b
smaller_branchless(a::T, b::T) where {T<:Integer} = a*(a<b) + b*(b<=a)

@time smaller(2, 10)
@time smaller_branchless(2, 10)
@btime 1:1_000_000 .|> x->smaller(x, 10)
@btime 1:1_000_000 .|> x->smaller_branchless(x, 10)

@code_lowered smaller(2, 10)
@code_lowered smaller_branchless(2, 10)

@code_native smaller(2, 10)
@code_native smaller_branchless(2, 10)

to_upper(d::String) = to_upper(collect(d))
function to_upper(d::Vector{Char})
    for (i, v) in enumerate(d)
        if v >= 'a' && v <= 'z'
            d[i] -= 32
        end
    end
    d
end

function to_upper_native(d::AbstractString)
    uppercase(d)
end

to_upper_branchless(d::String) = to_upper_branchless(collect(d))
function to_upper_branchless(d::Vector{Char})
    for (i, v) in enumerate(d)
        d[i] -= 32* (v >= 'a' && v <= 'z')
    end
    d
end

to_upper_branchless_vec(d::String) = to_upper_branchless_vec(collect(d))
function to_upper_branchless_vec(d::Vector{Char})
    @. d - 32 * ((d >= 'a') & (d <= 'z'))
end

collect("oh, hi mark!") .- 32 .* ((collect("oh, hi mark!") .>= 'a') .& (collect("oh, hi mark!") .<= 'z'))
@time to_upper("oh, hi mark!")
@time to_upper_native("oh, hi mark!")
@time to_upper_branchless("oh, hi mark!")
@time to_upper_branchless_vec("oh, hi mark!")
@btime 1:1_000_000 .|> x->to_upper("oh, hi mark!")
@btime 1:1_000_000 .|> x->to_upper_native("oh, hi mark!")
@btime 1:1_000_000 .|> x->to_upper_branchless("oh, hi mark!")
@btime 1:1_000_000 .|> x->to_upper_branchless_vec("oh, hi mark!")

@code_native to_upper("oh, hi mark!")
@code_native to_upper_native("oh, hi mark!")
@code_native to_upper_branchless("oh, hi mark!")
@code_native to_upper_branchless_vec("oh, hi mark!")

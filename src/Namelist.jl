mutable struct NamelistName
    n::String
end

Tokens = Vector{String}



NamelistItems = Union{Vector{Tokens}, NamedTuple, Dict}

mutable struct Namelist
    Name::NamelistName
    Contents::NamelistItems
end


#TODO for each basic Fortran datatype 
function comprehend(c::Tokens)

    return 0
end



using F90NML.FortranToJulia

function join_mult_lines(
    token_list::Vector{Vector{String}}
    )::Vector{Vector{String}}
    ret   = []
    stack = []
    for token_line in token_list
        if "=" ∈ token_line
            if length(stack) == 0
                push!(stack, token_line)
            else
                push!(ret, vcat(stack...))
                stack = []
            end
        elseif "/" ∉ token_line
            if length(stack) > 0
                push!(stack, token_line)
            else
                push!(ret, token_line)
            end
        else
            push!(ret, vcat(stack...))
            push!(ret, "/")
        end
    end
    return ret
end


function filter_whitespace(
    token_list::Vector{Vector{String}}
    )::Vector{Vector{String}}
    @inline all_whitespaces(x) = (x==="" || unique(x)==[Char(' ')])
    return [[tk for tk in tokens if !all_whitespaces(tk)] for tokens in token_list]
end


@inline isvalid_token_list(token_list::Vector{Vector{String}}) = 
    (token_list[1][1] == "&") && (token_list[end][1] == "/")

split_list(l::Vector, delim::String) = (
    _p_ = findfirst(l.==delim); 
    (isnothing(_p_) ? (l,[]) : (l[1:_p_-1],l[_p_+1:end]))
)

function to_dict(c)
    if (c isa Vector)
        return Dict(split_list(k,"=")[1]=>comprehend(split_list(k,"=")[2]) 
                    for k in c)
    elseif (c isa NamedTuple)
        return Dict(k=>c[k] for k in keys(c))
    elseif (c isa Dict)
        return c
    end
end


function Namelist(tk_lst::Vector{Vector{String}})
    token_list = filter_whitespace(join_mult_lines(tk_lst))
    @assert isvalid_token_list(token_list)
    return Namelist(
                NamelistName(token_list[1][end]), 
                to_dict(token_list[2:end-1])
           )
end

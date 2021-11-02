module FortranToJulia

import Base: parse

export FortranData, @f_str
export parse

struct FortranData{T <: AbstractString}
    data::T
end

macro f_str(str)
    return :(FortranData($str))
end

function parse(::Type{T}, s::FortranData)::T where {T <: Integer}
    Base.parse(T, s.data)
end

function parse(::Type{T}, s::FortranData)::T where {T <: Float32}
    Base.parse(T, replace(lowercase(s.data), r"(?<=[^e])(?=[+-])" => "f"))
end

function parse(::Type{T}, s::FortranData)::T where {T <: Float64}
    Base.parse(T, replace(lowercase(s.data), r"d"i => "e"))
end

function parse(::Type{Complex{T}}, s::FortranData)::Complex{T} where {T <: AbstractFloat}
    str = s.data
    if first(str) == '(' && last(str) == ')' && length(split(str, ',')) == 2
        re, im = split(str[2:end - 1], ',', limit = 2)
        return Complex(parse(T, re), parse(T, im))
    else
        throw(Meta.ParseError("$str must be in complex number form (x, y)."))
    end
end

function parse(::Type{Bool}, s::FortranData)::Bool
    str = lowercase(s.data)
    if str in (".true.", ".t.", "true", 't')
        return true
    elseif str in (".false.", ".f.", "false", 'f')
        return false
    else
        throw(Meta.ParseError("$str is not a valid logical constant."))
    end
end

function parse(::Type{T}, s::FortranData)::T where {T <: AbstractString}
    str = s.data
    m = match(r"([\"'])((?:\\\1|.)*?)\1", str)
    isnothing(m) && throw(Meta.ParseError("$str is not a valid string!"))
    quotation_mark, content = m.captures
    # Replace escaped strings
    return string(replace(content, repeat(quotation_mark, 2) => quotation_mark))
end

end

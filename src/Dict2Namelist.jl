using F90NML.JuliaToFortran

export dict2nml

function dict2nml(
    d::Dict, 
    name::AbstractString;
    dict_key_filter = x->(x isa AbstractString),
    dict_key_converter = x->string(x),
    )
    return [
        String["&", name],
        [
            String[dict_key_converter(k), "=", string(to_fortran(v))] 
            for (k,v) in d if dict_key_filter(k)
        ]...,
        ["/"],
        []
    ]
end
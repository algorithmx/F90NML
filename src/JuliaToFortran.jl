module JuliaToFortran

import Base: string

export string
export to_fortran
using Printf

using F90NML.FortranToJulia
 

to_fortran(v::Int)::FortranData = 
    FortranData(string(v))

to_fortran(v::Float32; scientific::Bool=false)::FortranData = 
    #str = string(v)
    #scientific && return FortranData(replace(str, r"f"i => "e"))
    FortranData(scientific ? strip((@sprintf  "%20.8e"  v))
                           : strip((@sprintf  "%g"      v)))

to_fortran(v::Float64; scientific::Bool=false)::FortranData = 
    #str = string(v)
    #scientific && return FortranData(replace(str, r"e"i => "d"))
    FortranData(scientific ? replace(strip((@sprintf  "%3.15e"  v)), 
                                     r"e"i => "d")
                           : strip((@sprintf   "%20.15f"  v)))

to_fortran(v::Bool)::FortranData =
    (v ? FortranData(".true.") : FortranData(".false."))

to_fortran(v::AbstractString)::FortranData = FortranData("'$v'")

string(s::FortranData) =  Base.string(s.data)

end

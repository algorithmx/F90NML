using F90NML
using Test

@testset "F90NML.jl" begin
    include("FortranToJuliaTests.jl")
    include("TokenizeTests.jl")
end

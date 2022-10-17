using Test
using PkgDependency

@testset "Make sure function runs without error" begin
    PkgDependency.tree()
    PkgDependency.tree("Term")
end

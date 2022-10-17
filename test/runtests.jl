using Test
using PkgDependency
import Term: Tree

@testset "Make sure function runs without error" begin
    @test PkgDependency.tree() isa Tree
    @test PkgDependency.tree("Term") isa Tree
end

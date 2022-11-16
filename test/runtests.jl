using Test
using PkgDependency
import Term: Tree

@testset "Make sure function runs without error" begin
    for compat in [true; false]
        @test PkgDependency.tree(; compat) isa Tree
        @test PkgDependency.tree("Term"; compat) isa Tree
        @test PkgDependency.tree("Term"; reverse=true, compat) isa Tree
        if VERSION < v"1.7"
            @test_throws ErrorException PkgDependency.tree("Term"; compat, show_link=true) isa Tree
        else
            @test PkgDependency.tree("Term"; compat, show_link=true) isa Tree
        end
    end
end

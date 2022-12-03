using Test
using PkgDependency
import Term: Tree

@testset "Make sure function runs without error" begin
    for dedup in [true; false]
    for compat in [true; false]
        @test PkgDependency.tree(; compat, dedup) isa Tree
        @test PkgDependency.tree("Term"; compat, dedup) isa Tree
        @test PkgDependency.tree("Term"; reverse=true, compat, dedup) isa Tree
        if VERSION < v"1.7"
            @test_throws ErrorException PkgDependency.tree("Term"; compat, show_link=true, dedup) isa Tree
        else
            @test PkgDependency.tree("Term"; compat, show_link=true, dedup) isa Tree
        end
    end
    end
end

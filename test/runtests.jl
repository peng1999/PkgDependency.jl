using Test
using PkgDependency
import Term: Tree

@testset "Make sure function runs without error" begin
    for dedup in [true; false]
    for compat in [true; false]
    for stdlib in [true; false]
    for maxdepth in [99; 1; 2]
        @test PkgDependency.tree(; compat, dedup, stdlib, maxdepth) isa Tree
        @test PkgDependency.tree("Term"; compat, dedup, stdlib, maxdepth) isa Tree
        @test PkgDependency.tree("Term"; reverse=true, compat, dedup, stdlib, maxdepth) isa Tree
        if VERSION < v"1.7"
            @test_throws ErrorException PkgDependency.tree("Term"; compat, show_link=true, dedup, stdlib, maxdepth) isa Tree
        else
            @test PkgDependency.tree("Term"; compat, show_link=true, dedup, stdlib, maxdepth) isa Tree
        end
    end
    end
    end
    end
end

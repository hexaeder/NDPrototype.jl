@testset "test utils" begin
    @testset begin
        using InteractiveUtils
        for t in subtypes(NDPrototype.Coupling)
            println(NDPrototype._styled_coupling(t()))
        end
    end

    @testset "subscript" begin
        using NDPrototype: subscript
        @test subscript(10) == "₁₀"
        @test subscript(5) == "₅"
    end

    @testset "style symbol array" begin
        using NDPrototype: stylesymbolarray
        syms = [:a, :b, :c]
        defaults = [1, 2, nothing]
        stylesymbolarray(syms, defaults, Dict(1 => :red, 2 => :orange))
        stylesymbolarray(syms, defaults, Dict(1 => :red, 2 => :red))
        NDPrototype.ND_FACES
    end

    @testset "find_identical" begin
        using NDPrototype: _find_identical

        v1 = Lib.kuramoto_second()
        @test _find_identical(v1, 1:10) == [collect(1:10)]
        v2 = Lib.diffusion_vertex()
        v3 = Lib.diffusion_vertex_constraint()

        # v2 and v3 are equal when it comes to the function!!
        vs = [v1,v2,v3,v2,v2,v1,v1,v3]

        @test _find_identical(vs, eachindex(vs)) == [[1,6,7],[2,3,4,5,8]]

        es = [Lib.diffusion_edge(),
              Lib.diffusion_edge_closure(),
              Lib.diffusion_edge_closure(),
              Lib.diffusion_edge_fid()]
        @test _find_identical(es, eachindex(es)) == [[1], [2], [3], [4]]
    end

    @testset "greedy edge coloring" begin
        using NDPrototype: color_edges_greedy, isvalid
        for i in 1:20
            g = complete_graph(i)
            colors = color_edges_greedy(g)
            @test isvalid(g, colors)
        end
    end
end

@testset "nd construction tests" begin
    using NDPrototype: StateType, statetype, isdense
    g = complete_graph(10)
    vertexf = ODEVertex(; f=x -> x^2, dim=1, pdim=2)
    @test statetype(vertexf) == NDPrototype.Dynamic()

    edgef = StaticEdge(; f=x -> x^2,
        dim=2, pdim=3,
        coupling=AntiSymmetric())
    @test statetype(edgef) == NDPrototype.Static()

    nd = Network(g, vertexf, edgef; verbose=false)

    @test statetype(only(nd.vertexbatches)) == NDPrototype.Dynamic()
    @test statetype(only(nd.layer.edgebatches)) == NDPrototype.Static()
    @test isdense(nd.im)
    @test nd.im.lastidx_dynamic == nv(g)
    @test nd.im.lastidx_static == nd.im.lastidx_dynamic + ne(g) * 2
    @test nd.vertexbatches isa Tuple
    @test nd.layer.edgebatches isa Tuple

    using NDPrototype: statetype
    g = complete_graph(10)
    vertexf = ODEVertex(; f=x -> x^2, dim=1, pdim=2)
    edgef = StaticEdge(; f=x -> x^2, dim=2, pdim=3, coupling=AntiSymmetric())

    using NDPrototype: SequentialExecution
    nd = Network(g, vertexf, edgef; verbose=false, execution=SequentialExecution{true}())

    nd = Network(g, vertexf, edgef; verbose=false,
        execution=SequentialExecution{false}())
end

@testset "Vertex batch" begin
    using NDPrototype: BatchStride, VertexBatch, parameter_range
    vb = VertexBatch{ODEVertex, typeof(sum)}([1, 2, 3, 4], # vertices
        sum, # function
        BatchStride(1, 3),
        BatchStride(4, 2),
        BatchStride(0, 0))
    @test parameter_range(vb, 1) == 4:5
    @test parameter_range(vb, 2) == 6:7
    @test parameter_range(vb, 3) == 8:9
    @test parameter_range(vb, 4) == 10:11
end

@testset "massmatrix construction test" begin
    using LinearAlgebra: I, UniformScaling, Diagonal
    v1 = ODEVertex(x->x^1, 2, 0; mass_matrix=I)
    v2 = ODEVertex(x->x^2, 2, 0; mass_matrix=Diagonal([2,0]))
    v3 = ODEVertex(x->x^3, 2, 0; mass_matrix=[1 2;3 4])
    v4 = ODEVertex(x->x^4, 2, 0; mass_matrix=UniformScaling(0))
    v5 = ODEVertex(x->x^5, 2, 0; mass_matrix=I)
    e1 = ODEEdge(x->x^1, 2, 0, Fiducial(); mass_matrix=I)
    e2 = ODEEdge(x->x^2, 2, 0, AntiSymmetric(); mass_matrix=Diagonal([2,0]))
    e3 = ODEEdge(x->x^3, 2, 0, NDPrototype.Symmetric(); mass_matrix=[1 2;3 4])
    e4 = ODEEdge(x->x^3, 2, 0, Directed(); mass_matrix=UniformScaling(0))
    nd = Network(path_graph(5), [v1,v2,v3,v4,v5], [e1,e2,e3,e4])

    mm = Matrix(Diagonal([1,1,2,0,1,4,0,0,1,1,1,1,2,0,1,4,0,0]))
    mm[5,6] = 2
    mm[6,5] = 3
    mm[15,16] = 2
    mm[16,15] = 3

    @test nd.mass_matrix == mm

    nd = Network(path_graph(4), [v1,v2,v4,v5], [e1,e2,e4])
    @test nd.mass_matrix isa Diagonal

    nd = Network(path_graph(4), [v1,v1,v1,v1], [e1,e1,e1])
    @test nd.mass_matrix == I && nd.mass_matrix isa UniformScaling
end

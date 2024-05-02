# exported items: experimental/GraphicalModels/src/GraphicalModels.jl
# TODOs:
# * fix tests for markov model
# * how to check e.g. collect(values(compute_equivalent_classes(probability_map(model)))) agains something hardcoded?

@testset "Graphical Models tests" begin

  tree = graph_from_edges(Directed,[[4,1],[4,2],[4,3]])

  @testset "Jukes Cantor" begin
    model = jukes_cantor_model(tree)
    @test is_isomorphic(graph(model), graph_from_edges(Directed,[[4,1],[4,2],[4,3]]))
    @test Oscar.number_states(model) == 4
    @test model isa GroupBasedPhylogeneticModel
    #check transition matricies
    tr_mat = Oscar.transition_matrices(model)
    for i in 1:4, j in 1:4
      @test tr_mat[Edge(4, 2)][1, i == j ? 1 : 2] == tr_mat[Edge(4, 2)][i, j] #
    end
  end

  @testset "kimura2_model" begin
    model = kimura2_model(tree)         
    @test is_isomorphic(graph(model), graph_from_edges(Directed,[[4,1],[4,2],[4,3]]))
    @test Oscar.number_states(model) == 4
    @test model isa GroupBasedPhylogeneticModel
    tr_mat = Oscar.transition_matrices(model)
    #check transition matricies
    for i in 1:4, j in 1:4
      @test tr_mat[Edge(4, 2)][1, (i == j ? 1 : (isodd(i+j) ? 2 : 3))] == tr_mat[Edge(4, 2)][i, j]
    end
  end
    
  @testset "cavender_farris_neyman_model" begin
    model = cavender_farris_neyman_model(tree)         
    @test is_isomorphic(graph(model), graph_from_edges(Directed,[[4,1],[4,2],[4,3]]))
    @test Oscar.number_states(model) == 2
    @test model isa GroupBasedPhylogeneticModel
    tr_mat = Oscar.transition_matrices(model)
    @test tr_mat[Edge(4, 2)][1,1] == tr_mat[Edge(4, 2)][2,2]
    @test tr_mat[Edge(4, 2)][1,2] == tr_mat[Edge(4, 2)][2,1]
  end

  @testset "kimura3_model" begin
    model = kimura3_model(tree)         
    @test is_isomorphic(graph(model), graph_from_edges(Directed,[[4,1],[4,2],[4,3]]))
    @test Oscar.number_states(model) == 4
    @test model isa GroupBasedPhylogeneticModel
    tr_mat = Oscar.transition_matrices(model)
    @test tr_mat[Edge(4, 2)][1,1] == tr_mat[Edge(4, 2)][2,2] == tr_mat[Edge(4, 2)][3,3] == tr_mat[Edge(4, 2)][4,4]
    @test tr_mat[Edge(4, 2)][2,1] == tr_mat[Edge(4, 2)][1,2] == tr_mat[Edge(4, 2)][4,3] == tr_mat[Edge(4, 2)][3,4]
    @test tr_mat[Edge(4, 2)][1,3] == tr_mat[Edge(4, 2)][3,1] == tr_mat[Edge(4, 2)][2,4] == tr_mat[Edge(4, 2)][4,2]
    @test tr_mat[Edge(4, 2)][1,4] == tr_mat[Edge(4, 2)][4,1] == tr_mat[Edge(4, 2)][2,3] == tr_mat[Edge(4, 2)][3,2]
  end

  #=@testset "general_markov_model" begin
    model = general_markov_model(tree)         
    @test is_isomorphic(graph(model), graph_from_edges(Directed,[[4,1],[4,2],[4,3]]))
    #@test Oscar.number_states(model) == 4
    @test model isa GroupBasedPhylogeneticModel
  end=#

  #Now we test functionalities for one tree and one model
  model = jukes_cantor_model(tree)

  @testset "probability map" begin 
    @test length(probability_map(model))== 64
  end

  @testset "fourrier map" begin
    @test length(fourier_map(model)) == 64
  end

  @testset "compute_equivalence_classes fuctions" begin
    #check that number of equivalence classes is correct
    @test length(compute_equivalent_classes(probability_map(model))) == 5
    #collect(values(compute_equivalent_classes(probability_map(model))))
    #check that number of equivalence classes in fourrier coordinates is correct
    @test length(compute_equivalent_classes(fourier_map(model))) == 6
  end

  @testset "transformation matrices" begin
  end
end
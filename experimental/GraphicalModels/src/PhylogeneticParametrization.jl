###################################################
#### PARAMETRIZATION IN PROBABLITY COORDINATES ####
###################################################

function monomial_parametrization(pm::PhylogeneticModel, states::Dict{Int, Int})
  gr = graph(pm)
  tr_mat = transition_matrices(pm)
  root_dist = root_distribution(pm)

  r = root(gr)
  monomial = root_dist[states[r]]
  for edge in edges(gr)
    stateParent = states[src(edge)]
    stateChild = states[dst(edge)]
    monomial = monomial * tr_mat[edge][stateParent, stateChild]
  end

  return monomial
end
function monomial_parametrization(pm::GroupBasedPhylogeneticModel, states::Dict{Int, Int})
  monomial_parametrization(phylogenetic_model(pm), states)
end

function probability_parametrization(pm::PhylogeneticModel, leaves_states::Vector{Int})
  gr = graph(pm)
  int_nodes = interior_nodes(gr)
  lvs_nodes = leaves(gr)
  n_states = number_states(pm)

  interior_indices = collect.(Iterators.product([collect(1:n_states) for _ in int_nodes]...))  
  nodes_states = Dict(lvs_nodes[i] => leaves_states[i] for i in 1:length(lvs_nodes))

  poly = 0
  # Might be useful in the future to use a polynomial ring context
  for labels in interior_indices
    for (int_node, label) in zip(int_nodes, labels)
      nodes_states[int_node] = label
    end
    poly = poly + monomial_parametrization(pm, nodes_states)
  end 
  return poly
end 
function probability_parametrization(pm::GroupBasedPhylogeneticModel, leaves_states::Vector{Int})
  probability_parametrization(phylogenetic_model(pm), leaves_states)
end
 
@doc raw"""
    probability_map(pm::PhylogeneticModel)    

Create a parametrization for a `PhylogeneticModel` of type `Dictionary`.

Iterate through all possible states of the leaf random variables and calculates their corresponding probabilities using the root distribution and laws of conditional independence. Return a dictionary of polynomials indexed by the states. Use auxiliary function `monomial_parametrization(pm::PhylogeneticModel, states::Dict{Int, Int})` and `probability_parametrization(pm::PhylogeneticModel, leaves_states::Vector{Int})`. 

# Examples
```jldoctest parametrization
julia> pm = jukes_cantor_model(graph_from_edges(Directed,[[4,1],[4,2],[4,3]]));

julia> p = probability_map(pm)
Dict{Tuple{Vararg{Int64}}, QQMPolyRingElem} with 64 entries:
  (1, 2, 1) => 1//4*a[1]*a[3]*b[2] + 1//4*a[2]*b[1]*b[3] + 1//2*b[1]*b[2]*b[3]
  (3, 1, 1) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*a[3]*b[1] + 1//2*b[1]*b[2]*b[3]
  (4, 4, 2) => 1//4*a[1]*a[2]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//2*b[1]*b[2]*b[3]
  (1, 2, 3) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (3, 1, 3) => 1//4*a[1]*a[3]*b[2] + 1//4*a[2]*b[1]*b[3] + 1//2*b[1]*b[2]*b[3]
  (3, 2, 4) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (3, 2, 1) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (2, 1, 4) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (3, 2, 3) => 1//4*a[1]*a[3]*b[2] + 1//4*a[2]*b[1]*b[3] + 1//2*b[1]*b[2]*b[3]
  (2, 1, 1) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*a[3]*b[1] + 1//2*b[1]*b[2]*b[3]
  (1, 3, 2) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (1, 4, 2) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (2, 1, 3) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (2, 2, 4) => 1//4*a[1]*a[2]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//2*b[1]*b[2]*b[3]
  (4, 3, 4) => 1//4*a[1]*a[3]*b[2] + 1//4*a[2]*b[1]*b[3] + 1//2*b[1]*b[2]*b[3]
  (2, 2, 1) => 1//4*a[1]*a[2]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//2*b[1]*b[2]*b[3]
  (4, 4, 4) => 1//4*a[1]*a[2]*a[3] + 3//4*b[1]*b[2]*b[3]
  (4, 3, 1) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (3, 3, 2) => 1//4*a[1]*a[2]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//2*b[1]*b[2]*b[3]
  (4, 1, 2) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (4, 4, 1) => 1//4*a[1]*a[2]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//2*b[1]*b[2]*b[3]
  (2, 2, 3) => 1//4*a[1]*a[2]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//2*b[1]*b[2]*b[3]
  (3, 4, 2) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (4, 3, 3) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*a[3]*b[1] + 1//2*b[1]*b[2]*b[3]
  (4, 4, 3) => 1//4*a[1]*a[2]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//2*b[1]*b[2]*b[3]
  (4, 2, 2) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*a[3]*b[1] + 1//2*b[1]*b[2]*b[3]
  (1, 3, 4) => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  (2, 3, 2) => 1//4*a[1]*a[3]*b[2] + 1//4*a[2]*b[1]*b[3] + 1//2*b[1]*b[2]*b[3]
  ⋮         => ⋮
```
"""
function probability_map(pm::PhylogeneticModel)
  lvs_nodes = leaves(graph(pm))
  n_states = number_states(pm)

  leaves_indices = collect.(Iterators.product([collect(1:n_states) for _ in lvs_nodes]...))
  probability_coordinates = Dict{Tuple{Vararg{Int64}}, QQMPolyRingElem}(Tuple(leaves_states) => probability_parametrization(pm, leaves_states) for leaves_states in leaves_indices)
  return probability_coordinates
end
function probability_map(pm::GroupBasedPhylogeneticModel)
  probability_map(phylogenetic_model(pm))
end


################################################
#### PARAMETRIZATION IN FOURIER COORDINATES ####
################################################
  
function monomial_fourier(pm::GroupBasedPhylogeneticModel, leaves_states::Vector{Int})
  gr = graph(pm)
  param = fourier_parameters(pm)
  monomial = 1
  for edge in edges(gr)
    dsc = vertex_descendants(dst(edge), gr, [])
    elem = group_sum(pm, leaves_states[dsc])
    monomial = monomial * param[edge][which_group_element(pm, elem)]
  end
  return monomial
end
  
function fourier_parametrization(pm::GroupBasedPhylogeneticModel, leaves_states::Vector{Int})
  S = fourier_ring(pm)
  if is_zero_group_sum(pm, leaves_states) 
    poly = monomial_fourier(pm, leaves_states)
  else 
    poly = S(0)
  end

  return poly
end 


@doc raw"""
    fourier_map(pm::GroupBasedPhylogeneticModel)    

Create a parametrization for a `GroupBasedPhylogeneticModel` of type `Dictionary`.

Iterate through all possible states of the leaf random variables and calculates their corresponding probabilities using group actions and laws of conditional independence. Return a dictionary of polynomials indexed by the states. Use auxiliary function `monomial_fourier(pm::GroupBasedPhylogeneticModel, leaves_states::Vector{Int})` and `fourier_parametrization(pm::GroupBasedPhylogeneticModel, leaves_states::Vector{Int})`. 

# Examples
```jldoctest parametrization
julia> q = fourier_map(pm)
Dict{Tuple{Vararg{Int64}}, QQMPolyRingElem} with 64 entries:
  (1, 2, 1) => 0
  (3, 1, 1) => 0
  (4, 4, 2) => 0
  (1, 2, 3) => 0
  (3, 1, 3) => x[2, 1]*x[1, 2]*x[3, 2]
  (3, 2, 4) => x[1, 2]*x[2, 2]*x[3, 2]
  (3, 2, 1) => 0
  (2, 1, 4) => 0
  (3, 2, 3) => 0
  (2, 1, 1) => 0
  (1, 3, 2) => 0
  (1, 4, 2) => 0
  (2, 1, 3) => 0
  (2, 2, 4) => 0
  (4, 3, 4) => 0
  (2, 2, 1) => x[3, 1]*x[1, 2]*x[2, 2]
  (4, 4, 4) => 0
  (4, 3, 1) => 0
  (3, 3, 2) => 0
  (4, 1, 2) => 0
  (4, 4, 1) => x[3, 1]*x[1, 2]*x[2, 2]
  (2, 2, 3) => 0
  (3, 4, 2) => x[1, 2]*x[2, 2]*x[3, 2]
  (4, 3, 3) => 0
  (4, 4, 3) => 0
  (4, 2, 2) => 0
  (1, 3, 4) => 0
  (2, 3, 2) => 0
  ⋮         => ⋮
```
"""
function fourier_map(pm::GroupBasedPhylogeneticModel)
  lvs_nodes = leaves(graph(pm))
  n_states = number_states(pm)

  leaves_indices = collect.(Iterators.product([collect(1:n_states) for _ in lvs_nodes]...))
  fourier_coordinates = Dict{Tuple{Vararg{Int64}}, QQMPolyRingElem}(Tuple(leaves_states) => fourier_parametrization(pm, leaves_states) for leaves_states in leaves_indices)
  return fourier_coordinates
end


#####################################
#### COMPUTE EQUIVALENCE CLASSES ####
#####################################

@doc raw"""
    compute_equivalent_classes(parametrization::Dict{Tuple{Vararg{Int64}}, QQMPolyRingElem})

Given the parametrization of a `PhylogeneticModel`, cancel all duplicate entries and return equivalence classes of states which are attached the same probabilities.

# Examples
```jldoctest parametrization
julia> p_equivclasses = compute_equivalent_classes(p)
Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem} with 5 entries:
  [(1, 2, 2), (1, 3, 3), (1, 4, 4), (2, 1, 1), (2, 3, 3), (2, 4, 4), (3, 1, 1), (3, 2, 2), (3, 4, 4), (4, 1, 1), (4, 2, 2), (4, 3, 3)]           => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*a[3]*b[1] + 1//2*b[1]*b[2]*b[3]
  [(1, 2, 3), (1, 2, 4), (1, 3, 2), (1, 3, 4), (1, 4, 2), (1, 4, 3), (2, 1, 3), (2, 1, 4), (2, 3, 1), (2, 3, 4)  …  (3, 2, 1), (3, 2, 4), (3, 4… => 1//4*a[1]*b[2]*b[3] + 1//4*a[2]*b[1]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//4*b[1]*b[2]*b[3]
  [(1, 2, 1), (1, 3, 1), (1, 4, 1), (2, 1, 2), (2, 3, 2), (2, 4, 2), (3, 1, 3), (3, 2, 3), (3, 4, 3), (4, 1, 4), (4, 2, 4), (4, 3, 4)]           => 1//4*a[1]*a[3]*b[2] + 1//4*a[2]*b[1]*b[3] + 1//2*b[1]*b[2]*b[3]
  [(1, 1, 2), (1, 1, 3), (1, 1, 4), (2, 2, 1), (2, 2, 3), (2, 2, 4), (3, 3, 1), (3, 3, 2), (3, 3, 4), (4, 4, 1), (4, 4, 2), (4, 4, 3)]           => 1//4*a[1]*a[2]*b[3] + 1//4*a[3]*b[1]*b[2] + 1//2*b[1]*b[2]*b[3]
  [(1, 1, 1), (2, 2, 2), (3, 3, 3), (4, 4, 4)]                                                                                                   => 1//4*a[1]*a[2]*a[3] + 3//4*b[1]*b[2]*b[3]

julia> q_equivclasses = compute_equivalent_classes(q)
Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem} with 6 entries:
  [(2, 1, 2), (3, 1, 3), (4, 1, 4)]                                        => x[2, 1]*x[1, 2]*x[3, 2]
  [(2, 2, 1), (3, 3, 1), (4, 4, 1)]                                        => x[3, 1]*x[1, 2]*x[2, 2]
  [(1, 2, 2), (1, 3, 3), (1, 4, 4)]                                        => x[1, 1]*x[2, 2]*x[3, 2]
  [(2, 3, 4), (2, 4, 3), (3, 2, 4), (3, 4, 2), (4, 2, 3), (4, 3, 2)]       => x[1, 2]*x[2, 2]*x[3, 2]
  [(1, 1, 2), (1, 1, 3), (1, 1, 4), (1, 2, 1), (1, 2, 3), (1, 2, 4), (1, … => 0
  [(1, 1, 1)]                                                              => x[1, 1]*x[2, 1]*x[3, 1]
```
"""
function compute_equivalent_classes(parametrization::Dict{Tuple{Vararg{Int64}}, QQMPolyRingElem})
  polys = unique(collect(values(parametrization)))
  
  equivalent_keys = []
  for value in polys
      eqv_class = [key for key in keys(parametrization) if parametrization[key] == value]
      #sort!(eqv_class)
      append!(equivalent_keys, [eqv_class])
  end
  equivalenceclass_dictionary = Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem}(sort(equivalent_keys[i]) => parametrization[equivalent_keys[i][1]] for i in 1:length(equivalent_keys))
  return equivalenceclass_dictionary
end

@doc raw"""
  sum_equivalent_classes(equivalent_classes::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem})  

Take the output of the function `compute_equivalent_classes` for `PhylogeneticModel` and multiply by a factor to obtain probabilities as specified on the original small trees database.

# Examples
```jldoctest parametrization
julia> sum_equivalent_classes(q_equivclasses)
Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem} with 6 entries:
  [(2, 1, 2), (3, 1, 3), (4, 1, 4)]                                      => 3*x[2, 1]*x[1, 2]*x[3, 2]
  [(2, 2, 1), (3, 3, 1), (4, 4, 1)]                                      => 3*x[3, 1]*x[1, 2]*x[2, 2]
  [(1, 2, 2), (1, 3, 3), (1, 4, 4)]                                      => 3*x[1, 1]*x[2, 2]*x[3, 2]
  [(2, 3, 4), (2, 4, 3), (3, 2, 4), (3, 4, 2), (4, 2, 3), (4, 3, 2)]     => 6*x[1, 2]*x[2, 2]*x[3, 2]
  [(1, 1, 2), (1, 1, 3), (1, 1, 4), (1, 2, 1), (1, 2, 3), (1, 2, 4), (1… => 0
  [(1, 1, 1)]                                                            => x[1, 1]*x[2, 1]*x[3, 1]
```
"""
function sum_equivalent_classes(equivalent_classes::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem})
  return Dict(key => equivalent_classes[key]*length(vcat([key]...)) for key in keys(equivalent_classes))
end


##############################################
#### SPECIALIZED FOURIER TRANSFORM MATRIX ####
##############################################

@doc raw"""
specialized_fourier_transform(pm::GroupBasedPhylogeneticModel, p_equivclasses::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem}, q_equivclasses::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem})  

Reparametrize between a model specification in terms of probability and Fourier cooordinates. The input of equivalent classes is optional, if they are not entered they will be computed.

# Examples
```jldoctest parametrization
julia> specialized_fourier_transform(pm, p_equivclasses, q_equivclasses)
5×5 Matrix{QQMPolyRingElem}:
 1  1      1      1      1
 1  -1//3  -1//3  1      -1//3
 1  -1//3  1      -1//3  -1//3
 1  1      -1//3  -1//3  -1//3
 1  -1//3  -1//3  -1//3  1//3
```
"""
function specialized_fourier_transform(pm::GroupBasedPhylogeneticModel, p_equivclasses::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem}, q_equivclasses::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem})
  R = probability_ring(pm)
  ns = number_states(pm)

  np = length(p_equivclasses)
  nq = length(q_equivclasses) - 1

  ## We need to sort the equivalence classes: both inside each class as well as the collection of classes. 
  p_equivclasses_sorted = collect(keys(p_equivclasses))
  [sort!(p_eqclass) for p_eqclass in p_equivclasses_sorted]
  sort!(p_equivclasses_sorted)

  q_equivclasses = collect(keys(filter(x -> !is_zero(x.second), q_equivclasses)))
  [sort!(f_eqclass) for f_eqclass in q_equivclasses]
  sort!(q_equivclasses)

  H = R.(hadamard(matrix_space(ZZ, ns, ns)))

  specialized_ft_matrix = R.(Int.(zeros(nq, np)))
  for i in 1:nq
    current_fourier_classes = q_equivclasses[i]
    for j in 1:np
      current_prob_classes = p_equivclasses_sorted[j]
      current_entriesin_M = [prod([H[y,x] for (x,y) in zip(p,q)]) for p in current_prob_classes, q in current_fourier_classes]
      specialized_ft_matrix[i,j] = R.(1//(length(current_prob_classes)*length(current_fourier_classes))*sum(current_entriesin_M))
    end
  end
  return specialized_ft_matrix
end

function specialized_fourier_transform(pm::GroupBasedPhylogeneticModel)
  p_equivclasses = compute_equivalent_classes(probability_map(pm))
  q_equivclasses = compute_equivalent_classes(fourier_map(pm))
  specialized_fourier_transform(pm, p_equivclasses,q_equivclasses)
end

@doc raw"""
    inverse_specialized_fourier_transform(pm::GroupBasedPhylogeneticModel, p_equivclasses::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem}, q_equivclasses::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem}) 

Reparametrize between a model specification in terms of Fourier and probability cooordinates.

# Examples
```jldoctest parametrization
julia> inverse_specialized_fourier_transform(pm, p_equivclasses, q_equivclasses)
5×5 Matrix{QQMPolyRingElem}:
 1//16  3//16   3//16   3//16   3//8
 3//16  -3//16  -3//16  9//16   -3//8
 3//16  -3//16  9//16   -3//16  -3//8
 3//16  9//16   -3//16  -3//16  -3//8
 3//8   -3//8   -3//8   -3//8   3//4
```
"""
function inverse_specialized_fourier_transform(pm::GroupBasedPhylogeneticModel, p_equivclasses::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem}, q_equivclasses::Dict{Vector{Tuple{Vararg{Int64}}}, QQMPolyRingElem})
  R = probability_ring(pm)
  ns = number_states(pm)

  np = length(p_equivclasses)
  nq = length(q_equivclasses) - 1

  ## We need to sort the equivalence classes: both inside each class as well as the collection of classes. 
  p_equivclasses_sorted = collect(keys(p_equivclasses))
  [sort!(p_eqclass) for p_eqclass in p_equivclasses_sorted]
  sort!(p_equivclasses_sorted)

  q_equivclasses_sorted = collect(keys(filter(x -> !is_zero(x.second), q_equivclasses)))
  [sort!(f_eqclass) for f_eqclass in q_equivclasses_sorted]
  sort!(q_equivclasses_sorted)

  H = R.(hadamard(matrix_space(ZZ, ns, ns)))
  Hinv = 1//ns * H 

  inverse_spec_ft_matrix = R.(Int.(zeros(np, nq)))
  for i in 1:np
    current_prob_class = p_equivclasses_sorted[i]
    for j in 1:nq
      current_fourier_class = q_equivclasses_sorted[j]
      current_entriesin_Minv = [prod([Hinv[x,y] for (x,y) in zip(p,q)]) for p in current_prob_class, q in current_fourier_class] 
      inverse_spec_ft_matrix[i,j] = R.(sum(current_entriesin_Minv))
    end
  end
  return inverse_spec_ft_matrix
end

function inverse_specialized_fourier_transform(pm::GroupBasedPhylogeneticModel)
  p_equivclasses = compute_equivalent_classes(probability_map(pm))
  q_equivclasses = compute_equivalent_classes(fourier_map(pm))
  inverse_specialized_fourier_transform(pm, p_equivclasses,q_equivclasses)
end

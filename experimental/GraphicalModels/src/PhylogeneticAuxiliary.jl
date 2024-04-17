#### GROUP OPERATIONS #### 

# This function implements the group operation on Z2 x Z2 and is subsequently 
# used to check the condition given in the computation of the Fourier
# coordinates and to calculate the sum of the leaves beneath a given edge. 
function group_sum(pm::PhylogeneticModel, states::Vector{Int})
    group = group_model(pm)
  
    if (length(states) == 1)
      return(group[states[1]])
    end
  
    return sum(group[states]).%2
end
  
function which_group_element(pm::PhylogeneticModel, elem::Vector{Int64})
#function which_group_element(pm::PhylogeneticModel, elem::Vector{Vector{Int64}})
    group = group_model(pm)
    return findall([all(group[i].==elem) for i in 1:length(group)])[1]
end


#### OPERATIONS ON THE TREE #### 

function interior_nodes(graph::Graph)
  big_graph = Polymake.graph.Graph(ADJACENCY = pm_object(graph))
  degrees = big_graph.NODE_DEGREES
  return findall(x -> x > 1, degrees)
end

function leaves(graph::Graph)
  big_graph = Polymake.graph.Graph(ADJACENCY = pm_object(graph))
  degrees = big_graph.NODE_DEGREES
  return findall(x -> x == 1, degrees)
end

function vertex_descendants(v::Int, gr::Graph, desc::Vector{Any})
    lvs = leaves(gr)
    outn = outneighbors(gr, v)
  
    if v in lvs
      return([v])
    end
  
    innodes = setdiff(outn, lvs)
    d = unique(append!(desc, intersect(outn, lvs)))
   
    if length(innodes) > 0
        for i in innodes
            d = vertex_descendants(i, gr, d)
        end
        return(d)
    end
  
    return(d)
end

function cherries(graph::Graph)
  lvs = leaves(graph)
  #cherr = unique([outneighbors(graph, inneighbors(graph,l)[1]) for l in lvs])
  #cherr = cherr[findall(x -> length(intersect(x, lvs)) ==2, cherr)]
  cherry = []
  for l in lvs
      in_node = inneighbors(graph,l)[1]
      lvs_cherr = outneighbors(graph, inneighbors(graph,l)[1])
      if issubset(lvs_cherr, lvs) == 2
          cherry = append!(cherry, [[Edge(in_node, lvs_cherr[1]), Edge(in_node, lvs_cherr[2])]])
      end
  end
  
  return(unique(cherry))
end


## COMPUTE EQUIVALENCE CLASSES ##
# Given the dictionary of parametrisation, the functions below compute 
# the equivalence classes, one time as is, the second one as in the format 
# on the website: every polynomial is multiplied by 0.25 times the size of the equivalence class. 
function computeequivalenceclasses(parametrisation)
    possible_values = unique(collect(values(parametrisation)))
    
    equivalent_keys = []
    for value in possible_values
        eqv_class = [key for key in keys(parametrisation) if parametrisation[key] == value]
        #sort!(eqv_class)
        append!(equivalent_keys, [eqv_class])
    end
    equivalenceclass_dictionary = Dict(equivalent_keys[i] => parametrisation[equivalent_keys[i][1]] for i in 1:length(equivalent_keys))
    return equivalenceclass_dictionary
end


function sumvaluesequivalenceclasses(equivalenceclasses)
    return Dict(key => 1//4*equivalenceclasses[key]*size(key,1) for key in keys(equivalenceclasses))
end

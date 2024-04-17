@register_serialization_type PhylogeneticModel

function save_object(s::SerializerState, m::PhylogeneticModel)
  save_data_dict(s) do
    save_typed_object(s, graph(m), :graph)
    save_typed_object(s, number_states(m), :n_states)
  end
end


@register_serialization_type Oscar.PhylogeneticModel

function save_object(s::SerializerState, m::Oscar.PhylogeneticModel)
  save_data_dict(s) do
    save_typed_object(s, graph(m), :graph)
  end
end

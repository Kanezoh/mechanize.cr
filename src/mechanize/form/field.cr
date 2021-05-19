class MechanizeCr::FormContent::Field
  property :node, :value, :name
  def initialize(node : Node, value : String = node.fetch("value", ""), name : String = node.fetch("name", ""))
    @node = node
    @name = name
    #@raw_value = value
    @value = value
    #@type = node['type']
  end

  def query_value
    [[@name, @value || ""]]
  end
end

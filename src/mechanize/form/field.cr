class MechanizeCr::FormContent::Field
  property value   : String?
  getter name      : String
  getter type      : String
  getter raw_value : String?
  getter node      : Node | Myhtml::Node

  def initialize(node : Node | Myhtml::Node, value=nil)
    @node      = node
    @name      = node.fetch("name", "")
    @value     = value || node.fetch("value", nil)
    @type      = node.fetch("type", "")
    @raw_value = @value
  end

  def query_value
    [@name, @value || ""]
  end

  # returns DOM 'id' value 
  def dom_id
    node.fetch("id", "")
  end

  # returns DOM 'class' value 
  def dom_class
    node.fetch("class", "")
  end

  def inspect # :nodoc:
    "[%s:0x%x type: %s name: %s value: %s]" % [
      self.class.name.sub(/MechanizeCr::FormContent::/, "").downcase,
      object_id, type, name, value
    ]
  end
end

# This class represents &lt;input&gt; elements in the form.
class Mechanize::FormContent::Field
  # returns field's 'value' attribute
  property value : String?
  # returns field's 'name' attribute
  getter name : String
  # returns field's 'type' attribute
  getter type : String
  # returns field's 'value' attribute.
  # value property is changeable, but this property stores raw value.
  getter raw_value : String?
  getter node : Node | Lexbor::Node

  def initialize(node : Node | Lexbor::Node, value = nil)
    @node = node
    @name = node.fetch("name", "")
    @value = value || node.fetch("value", nil)
    @type = node.fetch("type", "")
    @raw_value = @value
  end

  def query_value
    [@name, @value || ""]
  end

  # returns field's 'id' value
  def dom_id
    node.fetch("id", "")
  end

  # returns field's 'class' value
  def dom_class
    node.fetch("class", "")
  end

  def inspect # :nodoc:
    "[%s:0x%x type: %s name: %s value: %s]" % [
      self.class.name.sub(/Mechanize::FormContent::/, "").downcase,
      object_id, type, name, value,
    ]
  end
end

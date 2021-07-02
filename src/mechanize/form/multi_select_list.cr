require "./option"

class MechanizeCr::FormContent::MultiSelectList
  getter node       : Myhtml::Node
  property values   : Array(String)
  getter name       : String
  getter type       : String
  property options  : Array(FormContent::Option)

  def initialize(node : Myhtml::Node)
    @node = node
    @name = node.fetch("name", "")
    @type = node.fetch("type", "")
    @values = Array(String).new
    @options = Array(FormContent::Option).new
    node.css("option").each { |n|
      @options << FormContent::Option.new(n, self)
    }
  end

  def select_none
    @values = Array(String).new
    options.each &.unselect
  end

  def select_all
    @values = Array(String).new
    options.each &.select
  end

  def selected_options
    options.select &.selected?
  end

  def values=(new_values)
    select_none
    new_values.each do |value|
      option = options.find { |o| o.value == value }
      if option.nil?
        @value.push(value)
      else
        option.select
      end
    end
  end

  def values
    @values + selected_options.map &.value
  end

  def query_value
    values ? values.map { |v| [name, v] } : nil
  end

  #def inspect # :nodoc:
  #  "[%s:0x%x type: %s name: %s value: %s]" % [
  #    self.class.name.sub(/MechanizeCr::FormContent::/, "").downcase,
  #    object_id, type, name, value
  #  ]
  #end
end

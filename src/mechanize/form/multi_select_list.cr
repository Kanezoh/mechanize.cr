require "./option"

# This class represents &lt;select multiple&gt;
class Mechanize::FormContent::MultiSelectList
  getter node : Lexbor::Node
  getter name : String
  getter type : String
  property values : Array(String)
  property options : Array(FormContent::Option)

  def initialize(node : Lexbor::Node)
    @node = node
    @name = node.fetch("name", "")
    @type = node.fetch("type", "")
    @values = Array(String).new
    @options = Array(FormContent::Option).new
    node.css("option").each { |n|
      @options << FormContent::Option.new(n, self)
    }
  end

  # set all options unchecked
  def select_none
    @values = Array(String).new
    options.each &.unselect
  end

  # set all options checked
  def select_all
    @values = Array(String).new
    options.each &.select
  end

  # returns all checked options
  def selected_options
    options.select &.selected?
  end

  # add new values to options
  def values=(new_values)
    select_none
    new_values.each do |value|
      option = options.find { |o| o.value == value }
      if option.nil?
        @values.push(value)
      else
        option.select
      end
    end
  end

  # return all option's values.
  def values
    @values + selected_options.map &.value
  end

  def query_value
    values ? values.map { |v| [name, v] } : nil
  end

  def inspect # :nodoc:
    "[%s:0x%x type: %s name: %s values: [%s]]" % [
      self.class.name.sub(/Mechanize::FormContent::/, "").downcase,
      object_id, type, name, values.join(','),
    ]
  end
end

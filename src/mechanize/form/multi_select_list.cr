require "./option"

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

  def inspect # :nodoc:
    "[%s:0x%x type: %s name: %s values: [%s]]" % [
      self.class.name.sub(/Mechanize::FormContent::/, "").downcase,
      object_id, type, name, values.join(','),
    ]
  end
end

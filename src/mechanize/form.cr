require "./form/field"
require "./form/check_box"
require "./form/radio_button"

class MechanizeCr::Form
  getter fields     : Array(FormContent::Field)
  getter checkboxes : Array(FormContent::CheckBox)
  getter radiobuttons : Array(FormContent::RadioButton)
  getter enctype    : String
  getter method     : String
  getter name       : String
  property action   : String

  def initialize(node : Node | Myhtml::Node)
    @enctype          = node.fetch("enctype", "application/x-www-form-urlencoded")
    @node             = node
    @fields           = Array(FormContent::Field).new
    @checkboxes       = Array(FormContent::CheckBox).new
    @radiobuttons     = Array(FormContent::RadioButton).new
    @action           = node.fetch("action", "")
    @method           = node.fetch("method", "GET").upcase
    @name             = node.fetch("name", "")
    #@clicked_buttons  = []
    #@page             = page
    #@mech             = mech

    #@encoding = node['accept-charset'] || (page && page.encoding) || nil
    #@ignore_encoding_error = false
    parse
  end

  def request_data
    query_params = build_query
    build_query_string(query_params)
  end

  def fields_with(criteria)
    value = Hash(String,String).new
    if String === criteria
      value = {"name" => criteria}
    else
      # TODO
      # when args whose type isn't String is given
    end
    f = fields.select do |field|
      value.all? do |k,v|
        v === field.name
      end
    end
    f.empty? ? nil : f
  end

  def field_with(criteria)
    f = fields_with(criteria)
    raise ElementNotFoundError.new(:field, criteria) if f.nil?
    f.first
  end

  private def parse
    @fields = Array(FormContent::Field).new
    @checkboxes = Array(FormContent::CheckBox).new
    @node.css("input").not_nil!.each do |html_node|
      html_node = html_node.as(Myhtml::Node)
      type = (html_node["type"] || "text").downcase
      case type
      when "checkbox"
        @checkboxes << FormContent::CheckBox.new(html_node, self)
      else
        @fields << FormContent::Field.new(html_node)
      end
    end
  end

  private def build_query_string(params : Array(Array(String)))
    params.reduce("") do |acc, arr|
      hash = { arr[0] => arr[1] }
      acc + URI::Params.encode(hash) + '&'
    end.rchop
  end

  private def build_query
    query = [] of Array(String)
    successful_controls = Array(FormContent::Field | FormContent::CheckBox).new
    fields.each do |elm|
      successful_controls << elm
    end
    checkboxes.each do |elm|
      if elm.checked
        successful_controls << elm
      end
    end
    successful_controls.each do |ctrl|
      value = ctrl.query_value
      next if value[0] == ""
      query.push(value)
    end
    query
  end
end

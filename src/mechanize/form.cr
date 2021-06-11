require "./form/field"
require "./form/check_box"

class MechanizeCr::Form
  getter fields     : Array(MechanizeCr::FormContent::Field)
  getter checkboxes : Array(MechanizeCr::FormContent::CheckBox)
  getter enctype    : String
  getter method     : String
  getter name       : String
  property action   : String

  def initialize(node : Node | Myhtml::Node)
    @enctype          = node.fetch("enctype", "application/x-www-form-urlencoded")
    @node             = node
    @fields           = Array(MechanizeCr::FormContent::Field).new
    @checkboxes       = Array(MechanizeCr::FormContent::CheckBox).new
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
    raise MechanizeCr::ElementNotFoundError.new(:field, criteria) if f.nil?
    f.first
  end

  private def parse
    @fields = Array(MechanizeCr::FormContent::Field).new
    @checkboxes = Array(MechanizeCr::FormContent::CheckBox).new
    @node.css("input").not_nil!.each do |html_node|
      html_node = html_node.as(Myhtml::Node)
      @fields << MechanizeCr::FormContent::Field.new(html_node)
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
    successful_controls = Array(MechanizeCr::FormContent::Field | MechanizeCr::FormContent::CheckBox).new
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
      query.push(value)
    end
    query
  end
end

require "./form/field"
require "./form/check_box"

class MechanizeCr::Form
  getter fields : Array(MechanizeCr::FormContent::Field)
  getter checkboxes : Array(MechanizeCr::FormContent::CheckBox)
  getter enctype : String
  property action : String

  def initialize(node : Node | Myhtml::Node)
    @enctype = node["enctype"]? ? node["enctype"] : "application/x-www-form-urlencoded"
    @node             = node
    @fields = Array(MechanizeCr::FormContent::Field).new
    @checkboxes = Array(MechanizeCr::FormContent::CheckBox).new
    #@action           = Mechanize::Util.html_unescape(node['action'])
    @action = node["action"]
    #@method           = (node['method'] || 'GET').upcase
    #@name             = node['name']
    #@clicked_buttons  = []
    #@page             = page
    #@mech             = mech
#
    #@encoding = node['accept-charset'] || (page && page.encoding) || nil
    #@ignore_encoding_error = false
    parse
  end

  def request_data
    query_params = build_query
    build_query_string(query_params)
  end

  def build_query
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

  def parse
    @fields = Array(MechanizeCr::FormContent::Field).new
    @checkboxes = Array(MechanizeCr::FormContent::CheckBox).new
    @node.css("input").not_nil!.each do |node|
    end
  end

  def build_query_string(params : Array(Array(String)))
    params.reduce("") do |acc, arr|
      hash = { arr[0] => arr[1] }
      acc + URI::Params.encode(hash) + '&'
    end.rchop
  end
end

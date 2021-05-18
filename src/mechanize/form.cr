require "./form/field"
require "./form/check_box"

class MechanizeCr::Form
  getter fields : Array(MechanizeCr::FormContent::Field)
  getter checkboxes : Array(MechanizeCr::FormContent::CheckBox)

  def initialize(node : Node)
    @enctype = node["enctype"] || "application/x-www-form-urlencoded"
    @node             = node
    @fields = Array(MechanizeCr::FormContent::Field).new
    @checkboxes = Array(MechanizeCr::FormContent::CheckBox).new
    #@action           = Mechanize::Util.html_unescape(node['action'])
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
  end

  def build_query()
    query = [] of String
    successful_controls = Array(MechanizeCr::FormContent::Field | MechanizeCr::FormContent::CheckBox).new
    fields.each do |elm|
      successful_controls << elm
    end
    checkboxes.each do |elm|
      if elm.checked
        successful_controls << elm
      end
    end
  end

  def parse
    @fields = Array(MechanizeCr::FormContent::Field).new
    @checkboxes = Array(MechanizeCr::FormContent::CheckBox).new
    @node.search("input").not_nil!.each do |node|
    end
  end
end

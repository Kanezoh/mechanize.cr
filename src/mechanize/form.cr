require "./form/field"
class MechanizeCr::Form
  getter fields : Array(MechanizeCr::FormContent::Field)

  def initialize(node : Hash(String, String))
    @enctype = node["enctype"] || "application/x-www-form-urlencoded"
    @node             = node
    @fields = Array(MechanizeCr::FormContent::Field).new
    #@action           = Mechanize::Util.html_unescape(node['action'])
    #@method           = (node['method'] || 'GET').upcase
    #@name             = node['name']
    #@clicked_buttons  = []
    #@page             = page
    #@mech             = mech
#
    #@encoding = node['accept-charset'] || (page && page.encoding) || nil
    #@ignore_encoding_error = false
    #parse
  end
end

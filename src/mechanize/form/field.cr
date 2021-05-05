class MechanizeCr::FormContent::Field
  def initialize(node : Hash(String, String), value : String = node["value"])
    @node = node
    #@name = Mechanize::Util.html_unescape(node['name'])
    #@raw_value = value
    #@value = if value.is_a? String
    #           Mechanize::Util.html_unescape(value)
    #         else
    #           value
    #         end
#
    #@type = node['type']
  end
end

class MechanizeCr::FormContent::Field
  property :node, :value
  def initialize(node : Hash(String, String), value : String = node["value"])
    @node = node
    #@name = Mechanize::Util.html_unescape(node['name'])
    #@raw_value = value
    @value = value
    #@type = node['type']
  end
end

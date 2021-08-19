class MechanizeCr::PageContent::Link
  getter node : Lexbor::Node
  getter page : Page
  getter mech : Mechanize
  getter href : String
  getter text : String

  def initialize(node, mech, page)
    @node = node
    @page = page
    @mech = mech
    @href = node.fetch("href", "")
    @text = node.inner_text
  end
end

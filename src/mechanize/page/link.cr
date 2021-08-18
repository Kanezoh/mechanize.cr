class MechanizeCr::PageContent::Link
  property node : Lexbor::Node
  property page : Page
  property mech : Mechanize

  def initialize(node, mech, page)
    @node = node
    @page = page
    @mech = mech
    # @attributes = node
    # @href       = node['href']
    # @text       = nil
    # @uri        = nil
  end
end

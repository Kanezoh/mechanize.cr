require "myhtml"
# This is a fake node used when sending post request. 
class Node < Hash(String,String)
  def css(str)
    [] of Hash(String,String)
  end

  def inner_text
    ""
  end
end

# This is a real Node got from html.
struct Myhtml::Node
  delegate :[], to: attributes
  delegate :[]=, to: attributes
  delegate :[]?, to: attributes
  delegate :fetch, to: attributes
end

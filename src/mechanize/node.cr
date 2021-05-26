require "myhtml"

# This is a fake node.
class Node < Hash(String,String)
  def css(str)
    [] of Hash(String,String)
  end
end


# This is a real Node.
struct Myhtml::Node
  delegate :[], to: attributes
  delegate :[]=, to: attributes
  delegate :[]?, to: attributes
  delegate :fetch, to: attributes
end

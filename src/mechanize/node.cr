# This is a fake node.
# Real node is represented by Myhtml::Node

class Node < Hash(String,String)
  def css(str)
    [] of Hash(String,String)
  end
end

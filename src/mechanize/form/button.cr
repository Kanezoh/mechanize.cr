# This class represents button related html element.
# <button>, and <input> whose type is button, reset, image, submit.
class Mechanize::FormContent::Button < Mechanize::FormContent::Field
  getter form_node : Node | Lexbor::Node

  def initialize(node : Node | Lexbor::Node, form_node : Node | Lexbor::Node, value = nil)
    @form_node = form_node
    super(node, value)
  end
end

require "./reset_button"
require "./submit_button"
require "./image_button"

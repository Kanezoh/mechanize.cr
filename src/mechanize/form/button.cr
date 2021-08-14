class MechanizeCr::FormContent::Button < MechanizeCr::FormContent::Field
  getter form_node : Node | Lexbor::Node
  def initialize(node : Node | Lexbor::Node, form_node : Node | Lexbor::Node, value=nil)
    @form_node = form_node
    super(node, value)
  end
end
require "./reset_button"
require "./submit_button"
require "./image_button"

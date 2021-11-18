# This class represents &lt;option&gt; of &lt;select&gt;
class Mechanize::FormContent::Option
  getter select_list : FormContent::MultiSelectList
  getter node : Lexbor::Node
  getter text : String
  getter value : String
  getter selected : Bool

  def initialize(node, select_list)
    @node = node
    @text = node.inner_text
    @value = (node["value"] || node.inner_text)
    @selected = node.has_key?("selected")
    @select_list = select_list # The select list this option belongs to
  end

  # Select this option
  def select
    unselect_peers
    @selected = true
  end

  # Unselect this option
  def unselect
    @selected = false
  end

  # Toggle the selection value of this option
  def click
    unselect_peers
    @selected = !@selected
  end

  # returns option checked or not
  def selected?
    @selected
  end

  private def unselect_peers
    return if MultiSelectList === @select_list

    @select_list.select_none
  end
end

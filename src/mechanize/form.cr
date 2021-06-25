require "./form/field"
require "./form/radio_button"
require "./form/check_box"
require "./form/text"
require "./form/hidden"
require "./form/button"
require "./utils/element_matcher"

class MechanizeCr::Form
  include MechanzeCr::ElementMatcher

  getter fields       : Array(FormContent::Field)
  getter checkboxes   : Array(FormContent::CheckBox)
  getter radiobuttons : Array(FormContent::RadioButton)
  getter buttons      : Array(FormContent::Button)
  getter enctype      : String
  getter method       : String
  getter name         : String
  property action     : String

  def initialize(node : Node | Myhtml::Node)
    @enctype          = node.fetch("enctype", "application/x-www-form-urlencoded")
    @node             = node
    @fields           = Array(FormContent::Field).new
    @checkboxes       = Array(FormContent::CheckBox).new
    @radiobuttons     = Array(FormContent::RadioButton).new
    @buttons          = Array(FormContent::Button).new
    @action           = node.fetch("action", "")
    @method           = node.fetch("method", "GET").upcase
    @name             = node.fetch("name", "")
    #@clicked_buttons  = []
    #@page             = page
    #@mech             = mech

    #@encoding = node['accept-charset'] || (page && page.encoding) || nil
    #@ignore_encoding_error = false
    parse
  end

  def request_data
    query_params = build_query
    build_query_string(query_params)
  end

  # generate fields_with and field_with methods.
  # These methods are used for finding nodes that matches conditions.
  # ex.) field_with("email") finds <input name="email">

  elements_with "field"
  elements_with "radiobutton"

  private def parse
    @node.css("input").not_nil!.each do |html_node|
      html_node = html_node.as(Myhtml::Node)
      type = (html_node["type"] || "text").downcase
      case type
      when "checkbox"
        checkboxes << FormContent::CheckBox.new(html_node, self)
      when "radio"
        radiobuttons << FormContent::RadioButton.new(html_node, self)
      when "button"
        buttons << FormContent::Button.new(html_node)
      when "submit"
        buttons << FormContent::SubmitButton.new(html_node)
      when"reset"
        buttons << FormContent::ResetButton.new(html_node)
      when "text"
        fields << FormContent::Text.new(html_node)
      when "hidden"
        fields << FormContent::Hidden.new(html_node)
      else
        fields << FormContent::Field.new(html_node)
      end
    end
  end

  private def build_query_string(params : Array(Array(String)))
    params.reduce("") do |acc, arr|
      hash = { arr[0] => arr[1] }
      acc + URI::Params.encode(hash) + '&'
    end.rchop
  end

  private def build_query
    query = [] of Array(String)
    successful_controls = Array(FormContent::Field | FormContent::CheckBox).new
    fields.each do |elm|
      successful_controls << elm
    end
    checkboxes.each do |elm|
      if elm.checked
        successful_controls << elm
      end
    end
    radio_groups = Hash(String, Array(FormContent::RadioButton)).new
    radiobuttons.each do |radio|
      name = radio.name
      radio_groups[name] = Array(FormContent::RadioButton).new unless radio_groups.has_key?(name)
      radio_groups[name] << radio
    end

    radio_groups.each_value do |g|
      checked = g.select(&.checked)
      if checked.uniq.size > 1
        #values = checked.map(&.value).join(', ').inspect
        #name = checked.first.name.inspect
        #raise Mechanize::Error,
        #      "radiobuttons #{values} are checked in the #{name} group, " \
        #      "only one is allowed"
        raise MechanizeCr::Error.new
      else
        successful_controls << checked.first unless checked.empty?
      end
    end

    successful_controls.each do |ctrl|
      value = ctrl.query_value
      next if value[0] == ""
      query.push(value)
    end
    query
  end
end

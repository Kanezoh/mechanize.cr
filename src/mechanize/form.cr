require "./form/field"
require "./form/radio_button"
require "./form/check_box"
require "./form/text"
require "./form/textarea"
require "./form/hidden"
require "./form/button"
require "./form/select_list"
require "./utils/element_matcher"

class Mechanize
  # This class represents the form tag of html.
  class Form
    include ElementMatcher

    getter node : Node | Lexbor::Node
    # returns hoge array of `Mechanize::FormContent::Field` in the form.
    getter fields : Array(FormContent::Field)
    # returns an array of input tags whose type is checkbox in the form.
    getter checkboxes : Array(FormContent::CheckBox)
    # returns an array of input tags whose type is radio in the form.
    getter radiobuttons : Array(FormContent::RadioButton)
    # returns an array of input tags whose type is select in the form.
    getter selectboxes : Array(FormContent::MultiSelectList)
    # returns an array of button tags and input tag whose type is button,submit,reset,image.
    getter buttons : Array(FormContent::Button)
    # returns form's 'enctype' attribute.
    getter enctype : String
    # returns form's 'method' attribute.
    getter method : String
    # returns form's 'name' attribute.
    getter name : String
    # return form's 'action' attribute.
    property action : String
    # returns the page which includes the form.
    getter page : Page?

    def initialize(node : Node | Lexbor::Node, page : Page? = nil)
      @enctype = node.fetch("enctype", "application/x-www-form-urlencoded")
      @node = node
      @fields = Array(FormContent::Field).new
      @checkboxes = Array(FormContent::CheckBox).new
      @radiobuttons = Array(FormContent::RadioButton).new
      @selectboxes = Array(FormContent::MultiSelectList).new
      @buttons = Array(FormContent::Button).new
      @action = node.fetch("action", "")
      @method = node.fetch("method", "GET").upcase
      @name = node.fetch("name", "")
      @clicked_buttons = Array(FormContent::Button).new
      @page = page
      # @mech             = mech

      # @encoding = node['accept-charset'] || (page && page.encoding) || nil
      # @ignore_encoding_error = false
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
    elements_with "checkbox", "checkboxes"
    elements_with "button"

    # Returns all fields of &lt;input type="textarea"&gt;
    def textareas
      fields.select { |f| f.class == FormContent::Textarea }.map &.as(FormContent::Textarea)
    end

    private def parse
      @node.css("input").not_nil!.each do |html_node|
        html_node = html_node.as(Lexbor::Node)
        type = (html_node["type"]? || "text").downcase
        case type
        when "checkbox"
          checkboxes << FormContent::CheckBox.new(html_node, self)
        when "radio"
          radiobuttons << FormContent::RadioButton.new(html_node, self)
        when "button"
          buttons << FormContent::Button.new(html_node, @node)
        when "submit"
          buttons << FormContent::SubmitButton.new(html_node, @node)
        when "reset"
          buttons << FormContent::ResetButton.new(html_node, @node)
        when "image"
          buttons << FormContent::ImageButton.new(html_node, @node)
        when "text"
          fields << FormContent::Text.new(html_node)
        when "hidden"
          fields << FormContent::Hidden.new(html_node)
        when "textarea"
          fields << FormContent::Textarea.new(html_node)
        else
          fields << FormContent::Field.new(html_node)
        end
      end

      # Find all textarea tags
      @node.css("textarea").each do |node|
        node = node.as(Lexbor::Node)
        next if node["name"].empty?
        @fields << FormContent::Textarea.new(node, node.inner_text)
      end

      @node.css("button").each do |node|
        node = node.as(Lexbor::Node)
        type = node.fetch("type", "submit").downcase
        next if type == "reset"
        @buttons << FormContent::Button.new(node, @node)
      end

      # Find all select tags
      @node.css("select").each do |node|
        node = node.as(Lexbor::Node)
        next if node["name"].empty?
        if node.has_key?("multiple")
          @selectboxes << FormContent::MultiSelectList.new(node)
        else
          @selectboxes << FormContent::SelectList.new(node)
        end
      end
    end

    private def build_query_string(params : Array(Array(String)))
      params.reduce("") do |acc, arr|
        hash = {arr[0] => arr[1]}
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
          # values = checked.map(&.value).join(', ').inspect
          # name = checked.first.name.inspect
          # raise Mechanize::Error,
          #      "radiobuttons #{values} are checked in the #{name} group, " \
          #      "only one is allowed"
          raise Error.new
        else
          successful_controls << checked.first unless checked.empty?
        end
      end

      @clicked_buttons.each do |b|
        successful_controls << b
      end

      successful_controls.each do |ctrl|
        value = ctrl.query_value
        next if value[0] == ""
        query.push(value)
      end

      @selectboxes.each do |s|
        value = s.query_value
        if value
          value.each do |v|
            query.push(v)
          end
        end
      end

      query
    end

    # This method adds a button to the query.  If the form needs to be
    # submitted with multiple buttons, pass each button to this method.
    def add_button_to_query(button)
      unless button.form_node == @node
        message = ""
        "#{button.inspect} does not belong to the same page as " \
        "the form #{@name.inspect} in #{@page.try &.uri}"
        message = "not a valid button"
        raise ArgumentError.new(message)
      end

      @clicked_buttons << button
    end
  end
end

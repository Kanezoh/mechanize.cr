require "./file"
require "./utils/element_matcher"

class MechanizeCr::Page < MechanizeCr::File
  include MechanzeCr::ElementMatcher
  delegate :css, to: parser

  def initialize(uri, response, body, code)
    super(uri, response, body, code)
  end

  def parser : Myhtml::Parser
    @parser ||=  Myhtml::Parser.new(@body)
  end

  def title
    title_node = css("title")
    if title_node.empty?
      ""
    else
      title_node.first.inner_text
    end
  end

  def forms
    forms = css("form").map do |html_form|
      form = Form.new(html_form, self)
      form.action ||= @uri.to_s
      form
    end.to_a
  end

  # generate form_with, forms_with methods
  # ex) form_with({:name => "login_form"})
  # it detects form(s) which match conditions.
  elements_with "form"
end

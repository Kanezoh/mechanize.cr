require "./file"
require "./utils/element_matcher"
require "./page/link"

class MechanizeCr::Page < MechanizeCr::File
  include MechanizeCr::ElementMatcher
  delegate :css, to: parser

  property mech : Mechanize

  def initialize(uri, response, body, code, mech)
    @mech = mech
    super(uri, response, body, code)
  end

  def parser : Lexbor::Parser
    @parser ||= Lexbor::Parser.new(@body)
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

  def links
    links = %w{a area}.map do |tag|
      css(tag).map do |node|
        PageContent::Link.new(node, @mech, self)
      end
    end.flatten
  end

  # generate form_with, forms_with methods
  # ex) form_with({:name => "login_form"})
  # it detects form(s) which match conditions.
  elements_with "form"
end

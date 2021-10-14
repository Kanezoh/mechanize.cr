require "./file"
require "./utils/element_matcher"
require "./page/link"

# This class represents the page of response.
# If you send request, it returns the instance of Page.
# You can get status code, title, and page body, and search html node using css selector.

class MechanizeCr::Page < MechanizeCr::File
  include MechanizeCr::ElementMatcher
  delegate :css, to: parser

  property mech : Mechanize

  def initialize(uri, response, body, code, mech)
    @mech = mech
    super(uri, response, body, code)
  end

  # parser to parse response body.
  # TODO: now it's Lexbor::Parser. I want to also support other parsers like JSON.
  def parser : Lexbor::Parser
    @parser ||= Lexbor::Parser.new(@body)
  end

  # return page title.
  def title : String
    title_node = css("title")
    if title_node.empty?
      ""
    else
      title_node.first.inner_text
    end
  end

  # return all forms(`MechanizeCr::Form`) in the page.
  def forms : Array(MechanizeCr::Form)
    forms = css("form").map do |html_form|
      form = Form.new(html_form, self)
      form.action ||= @uri.to_s
      form
    end.to_a
  end

  # return all links(`MechanizeCr::PageContent::Link) in the page.
  def links : Array(MechanizeCr::PageContent::Link)
    links = %w{a area}.map do |tag|
      css(tag).map do |node|
        PageContent::Link.new(node, @mech, self)
      end
    end.flatten
  end

  elements_with "form"
end

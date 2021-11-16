require "./file"
require "./utils/element_matcher"
require "./page/link"

# This class represents the result of http response.  
# If you send a request, it returns the instance of `MechanizeCr::Page`.  
# You can get status code, title, and page body, and search html node using css selector from page instance.
class MechanizeCr::Page < MechanizeCr::File
  include MechanizeCr::ElementMatcher

  # look at lexbor document.(https://github.com/kostya/lexbor#readme)
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
  # ```
  # page.title # => String
  # ```
  def title : String
    title_node = css("title")
    if title_node.empty?
      ""
    else
      title_node.first.inner_text
    end
  end

  # return all forms(`MechanizeCr::Form`) in the page.
  # ```
  # page.forms # => Array(MechanizeCr::Form)
  # ```
  def forms : Array(MechanizeCr::Form)
    forms = css("form").map do |html_form|
      form = Form.new(html_form, self)
      form.action ||= @uri.to_s
      form
    end.to_a
  end

  # return all links(`MechanizeCr::PageContent::Link`) in the page.
  # ```
  # page.links # => Array(MechanizeCr::PageContent::Link)
  # ```
  def links : Array(MechanizeCr::PageContent::Link)
    links = %w{a area}.map do |tag|
      css(tag).map do |node|
        PageContent::Link.new(node, @mech, self)
      end
    end.flatten
  end

  elements_with "form"
end

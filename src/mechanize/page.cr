require "./file"
require "./utils/element_matcher"
require "./page/link"

class Mechanize
  # This class represents the result of http response.
  # If you send a request, it returns the instance of `Mechanize::Page`.
  # You can get status code, title, and page body, and search html node using css selector from page instance.
  class Page < Mechanize::File
    include ElementMatcher

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

    # return all forms(`Mechanize::Form`) in the page.
    # ```
    # page.forms # => Array(Mechanize::Form)
    # ```
    def forms : Array(Form)
      css("form").map do |html_form|
        form = Form.new(html_form, self)
        form.action ||= @uri.to_s
        form
      end
    end

    # return all links(`Mechanize::PageContent::Link`) in the page.
    # ```
    # page.links # => Array(Mechanize::PageContent::Link)
    # ```
    def links : Array(PageContent::Link)
      %w{a area}.flat_map do |tag|
        css(tag).map do |node|
          PageContent::Link.new(node, @mech, self)
        end
      end
    end

    elements_with "form"
  end
end

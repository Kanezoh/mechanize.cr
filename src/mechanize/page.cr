require "./file"

class MechanizeCr::Page < MechanizeCr::File
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
      form = MechanizeCr::Form.new(html_form)
      form.action ||= @uri.to_s
      form
    end.to_a
  end
end

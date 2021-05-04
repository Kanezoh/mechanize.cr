require "myhtml"
require "./file"

class MechanizeCr::Page < MechanizeCr::File
  delegate :css, to: parser

  def initialize(uri, response, body, code)
    super(uri, response, body, code)
  end

  def parser : Myhtml::Parser
    @parser ||=  Myhtml::Parser.new(@body)
  end
end

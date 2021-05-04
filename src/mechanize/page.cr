require "myhtml"
require "./file"

class MechanizeCr::Page < MechanizeCr::File
  def initialize(uri, response, body, code)
    super(uri, response, body, code)
  end

  def parser
    return @parser if @parser
    return unless @body
    @parser = Myhtml::Parser.new(@body)
  end
end

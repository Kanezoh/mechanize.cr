require "./base_error"

class Mechanize::ElementNotFoundError < Mechanize::Error
  getter element : Symbol
  getter conditions : String

  def initialize(element, conditions)
    @element = element
    @conditions = conditions

    super "Element #{element} with conditions #{conditions} was not found"
  end
end

require "./file"
class MechanizeCr::Page < MechanizeCr::File
  def initialize(uri, response, body, code)
    super(uri, response, body, code)
  end
end

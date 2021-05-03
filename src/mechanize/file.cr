require "http/client"
class MechanizeCr::File
  #property :body, :filename
  property :body, :code
  def initialize(uri : String | Nil, response : ::HTTP::Client::Response | Nil, body : String , code : Int32 | Nil)
    @uri  = uri
    @body = body
    @code = code

    #@full_path = false unless defined? @full_path

    #fill_header response
    #extract_filename

    #yield self if block_given?
  end
end

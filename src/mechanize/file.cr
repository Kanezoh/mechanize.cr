require "http/client"
class MechanizeCr::File
  #property :body, :filename
  property :body, :code, uri, :response
  def initialize(uri : URI, response : ::HTTP::Client::Response, body : String , code : Int32)
    @uri  = uri
    @body = body
    @code = code

    #@full_path = false unless defined? @full_path

    #fill_header response
    #extract_filename

    #yield self if block_given?
  end
end

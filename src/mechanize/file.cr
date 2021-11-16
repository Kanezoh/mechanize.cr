require "http/client"

class Mechanize
  class File
    # property :body, :filename
    property :body, :code, uri, :response

    def initialize(uri : URI, response : ::HTTP::Client::Response, body : String, code : Int32)
      @uri = uri
      @body = body
      @code = code
    end
  end
end

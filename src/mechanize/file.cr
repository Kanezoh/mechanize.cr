class Mechanize
  abstract class File
    # property :filename

    # returns http response body
    getter body : String
    # returns http status code
    getter code : Int32
    # returns page uri
    getter uri : URI

    def initialize(uri : URI, response : ::HTTP::Client::Response, body : String, code : Int32)
      @uri = uri
      @body = body
      @code = code
    end
  end
end

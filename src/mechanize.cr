require "./mechanize/http/agent"
require "./mechanize/page"

class Mechanize
  VERSION = "0.1.0"

  def initialize()
    @agent = MechanizeCr::HTTP::Agent.new
    @agent.context = self
  end

  def get(uri : String | URI, headers = HTTP::Headers.new, params : Hash(String, String | Array(String)) = Hash(String,String).new)
    method = :get
    page = @agent.fetch uri, method, headers, params
    #add_to_history(page)
    #yield page if block_given?
    page
  end

  def request_headers
    @agent.request_headers
  end

  def request_headers=(request_headers)
    @agent.request_headers = request_headers
  end

  def parse(uri, response, body)
    code = response.not_nil!.status_code
    MechanizeCr::Page.new(uri, response, body, code)
  end
end

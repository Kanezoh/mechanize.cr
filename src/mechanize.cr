require "./http/agent"

class Mechanize
  VERSION = "0.1.0"

  def initialize()
    @agent = MechanizeCr::HTTP::Agent.new
  end

  def get(uri : String | URI, headers = HTTP::Headers.new)
    method = :get
    page = @agent.fetch uri, method, headers
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
end

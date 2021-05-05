require "./mechanize/http/agent"
require "./mechanize/form"

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

  def post(uri : String | URI, headers = HTTP::Headers.new, query : Hash(String, String | Array(String)) = Hash(String,String).new)
    node = Hash(String, String).new
    node["method"] = "POST"
    node["enctype"] = "application/x-www-form-urlencoded"

    form = MechanizeCr::Form.new(node)
    form.fields << MechanizeCr::FormContent::Field.new({"name" => "foo"}, "bar")
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

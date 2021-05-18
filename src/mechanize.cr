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
    query.each do |k,v|
      form.fields << MechanizeCr::FormContent::Field.new({"name" => k}, v)
    end
    #post_form(uri, form, headers)
  end

  def post_form(uri, form, headers)
    #cur_page = form.page || current_page ||
    #  Page.new

    request_data = form.request_data

    headers = {
      "Content-Type"    => form.enctype,
      "Content-Length"  => request_data.size.to_s,
    }.merge headers

    # fetch the page
    page = @agent.fetch uri, :post, headers, [request_data], cur_page
    add_to_history(page)
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

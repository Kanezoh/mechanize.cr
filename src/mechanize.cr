require "./mechanize/http/agent"
require "./mechanize/form"
require "./mechanize/node"
require "./mechanize/page"
require "./mechanize/errors/*"

class Mechanize
  VERSION = "0.1.0"

  AGENT = {
    "Mechanize" => "Mechanize/#{VERSION} Crystal/#{Crystal::VERSION} (https://github.com/Kanezoh/mechanize.cr)",
  }

  def initialize
    @agent = MechanizeCr::HTTP::Agent.new
    @agent.context = self
    @agent.user_agent = AGENT["Mechanize"]
  end

  def get(uri : String | URI, headers = HTTP::Headers.new, params : Hash(String, String | Array(String)) = Hash(String, String).new)
    method = :get
    page = @agent.fetch uri, method, headers, params
    add_to_history(page)
    # yield page if block_given?
    page
  end

  def post(uri : String | URI, headers = HTTP::Headers.new, query : Hash(String, String | Array(String)) = Hash(String, String).new)
    node = Node.new
    node["method"] = "POST"
    node["enctype"] = "application/x-www-form-urlencoded"

    form = MechanizeCr::Form.new(node)
    query.each do |k, v|
      node = Node.new
      node["name"] = k
      form.fields << MechanizeCr::FormContent::Field.new(node, v)
    end
    post_form(uri, form, headers)
  end

  # send POST request from form.
  def post_form(uri, form, headers)
    cur_page = form.page || (current_page unless history.empty?)

    request_data = form.request_data
    content_headers = ::HTTP::Headers{
      "Content-Type"   => form.enctype,
      "Content-Length" => request_data.size.to_s,
    }
    headers.merge!(content_headers)

    # fetch the page
    page = @agent.fetch(uri, :post, headers: headers, params: {"value" => request_data}, referer: cur_page)
    headers.delete("Content-Type")
    headers.delete("Content-Length")
    add_to_history(page)
    page
  end

  def request_headers
    @agent.request_headers
  end

  def request_headers=(request_headers)
    @agent.request_headers = request_headers
  end

  def user_agent
    @agent.user_agent
  end

  def user_agent=(user_agent)
    @agent.user_agent = user_agent
  end

  def current_page
    @agent.current_page
  end

  def back
    @agent.history.pop
  end

  def submit(form, button = nil)
    form.add_button_to_query(button) if button
    case form.method.upcase
    when "POST"
      post_form(form.action, form, request_headers)
    end
  end

  def parse(uri, response, body)
    code = response.not_nil!.status_code
    MechanizeCr::Page.new(uri, response, body, code, self)
  end

  def history
    @agent.history
  end

  def add_to_history(page)
    history.push(page)
  end

  # Get maximum number of items allowed in the history.
  # The default setting is 100 pages.
  def max_history
    history.max_size
  end

  # Set maximum number of items allowed in the history.
  def max_history=(length)
    history.max_size = length
  end
end

require "./mechanize/http/agent"
require "./mechanize/form"
require "./mechanize/node"
require "./mechanize/page"
require "./mechanize/errors/*"

# This class is main class of Mechanize.cr,
# using this class' instance to start web interaction.
# 
# now only supports GET, POST. other HTTP methods will be implemented soon...
#
# Examples:
#
# ```
# # GET
# agent = Mechanize.new
# agent.get("http://example.com",
#           params: {"foo" => "bar"},
#           headers: HTTP::Headers{"Foo" => "Bar"})
# ```
# 
# ```
# # POST
# # sending post request whose post body is "foo=bar"
# agent = Mechanize.new
# agent.post("http://example.com",
#           query: {"foo" => "bar"})
# ```
class Mechanize
  VERSION = "0.2.0"

  AGENT = {
    "Mechanize" => "Mechanize/#{VERSION} Crystal/#{Crystal::VERSION} (https://github.com/Kanezoh/mechanize.cr)",
  }

  def initialize
    @agent = MechanizeCr::HTTP::Agent.new
    @agent.context = self
    @agent.user_agent = AGENT["Mechanize"]
  end

  def get(uri : String | URI,
          headers = HTTP::Headers.new,
          params : Hash(String, String | Array(String)) = Hash(String, String).new)
    method = :get
    page = @agent.fetch uri, method, headers, params
    add_to_history(page)
    # yield page if block_given?
    page
  end

  def post(uri : String | URI,
           headers = HTTP::Headers.new,
           query : Hash(String, String | Array(String)) = Hash(String, String).new)
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

  # click link, and return page.
  def click(link)
    href = link.href
    get href
  end

  # download page body from given uri.
  # TODO: except this request from history.
  def download(uri,
               filename,
               headers = HTTP::Headers.new,
               params : Hash(String, String | Array(String)) = Hash(String, String).new)
    transact do
      page = get(uri, headers, params)
      case page
      when MechanizeCr::File
        File.write(filename, page.body)
      end
    end
  end

  # Runs given block, then resets the page history as it was before.
  def transact
    # save the previous history status.
    history_backup = MechanizeCr::History.new(@agent.history.max_size, @agent.history.array.dup)
    begin
      yield self
    ensure
      # restore the previous history.
      @agent.history = history_backup
    end
  end
end

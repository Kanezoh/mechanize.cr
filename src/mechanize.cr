require "uri"
require "http/client"
require "lexbor"
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
# # send GET request to http://example.com/?foo=bar
# agent.get("http://example.com",
#   params: {"foo" => "bar"},
#   headers: HTTP::Headers{"Foo" => "Bar"})
# ```
#
# ```
# # POST
# # send POST request whose post body is "foo=bar"
# agent = Mechanize.new
# agent.post("http://example.com",
#   query: {"foo" => "bar"})
# ```
class Mechanize
  VERSION = "0.2.0"

  USER_AGENT = {
    "Mechanize" => "Mechanize/#{VERSION} Crystal/#{Crystal::VERSION} (https://github.com/Kanezoh/mechanize.cr)",
  }

  def initialize
    @agent = Mechanize::HTTP::Agent.new
    @agent.context = self
    @agent.user_agent = USER_AGENT["Mechanize"]
  end

  # Send GET request to specified uri with headers, and parameters.
  #
  # Examples (send request to http://example.com/?foo=bar)
  #
  # ```
  # agent = Mechanize.new
  # agent.get("http://example.com",
  #   params: {"foo" => "bar"},
  #   headers: HTTP::Headers{"Foo" => "Bar"})
  # ```
  def get(uri : String | URI,
          headers = ::HTTP::Headers.new,
          params : Hash(String, String | Array(String)) = Hash(String, String).new) : Mechanize::Page
    method = :get
    page = @agent.fetch uri, method, headers, params
    add_to_history(page)
    # yield page if block_given?
    page
  end

  # Send POST request to specified uri with headers, and query.
  #
  # Examples (send post request whose post body is "foo=bar")
  #
  # ```
  # agent = Mechanize.new
  # agent.post("http://example.com",
  #   query: {"foo" => "bar"},
  #   headers: HTTP::Headers{"Foo" => "Bar"})
  # ```
  def post(uri : String | URI,
           headers = ::HTTP::Headers.new,
           query : Hash(String, String | Array(String)) = Hash(String, String).new) : Mechanize::Page
    node = Mechanize::Node.new
    node["method"] = "POST"
    node["enctype"] = "application/x-www-form-urlencoded"

    form = Mechanize::Form.new(node)
    query.each do |k, v|
      node = Mechanize::Node.new
      node["name"] = k
      form.fields << Mechanize::FormContent::Field.new(node, v)
    end
    post_form(uri, form, headers)
  end

  # get the value of request headers.
  #
  # ```
  # agent.request_headers # => HTTP::Headers{"Foo" => "Bar"}
  # ```
  def request_headers : ::HTTP::Headers
    @agent.request_headers
  end

  # set the value of request headers.
  #
  # ```
  # agent.request_headers = HTTP::Headers{"Foo" => "Bar"}
  # ```
  def request_headers=(request_headers : ::HTTP::Headers)
    @agent.request_headers = request_headers
  end

  # get the value of user agent.
  #
  # ```
  # agent.user_agent # => "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; NP06; rv:11.0) like Gecko"
  # ```
  def user_agent : String
    @agent.user_agent
  end

  # set the value of user agent.
  #
  # ```
  # agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; NP06; rv:11.0) like Gecko"
  # ```
  def user_agent=(user_agent : String)
    @agent.user_agent = user_agent
  end

  # get the page mechanize last visited.
  #
  # ```
  # agent.current_page => #<Mechanize::Page>
  # ```
  def current_page : Mechanize::Page
    @agent.current_page
  end

  # get the latest page recorded in history, and the page is deleted from history.
  #
  # ```
  # agent.back => #<Mechanize::Page>
  # ```
  def back : Mechanize::Page
    @agent.history.pop
  end

  # send request from form. 'form' args is necessary, but 'button' is optional.
  # you can specify button if you want to use other button which is not in the form.
  # TODO: now only supports POST. other HTTP methods should be supported.
  #
  # ```
  # page = agent.get("http://example.com")
  # form = page.forms[0]
  # # set field value
  # form.field_with("foo").value = "bar"
  # agent.submit(form)
  # ```
  def submit(form, button = nil) : Mechanize::Page?
    form.add_button_to_query(button) if button
    case form.method.upcase
    when "POST"
      post_form(form.action, form, request_headers)
    end
  end

  # parse response. it is used internally.
  def parse(uri, response, body)
    code = response.not_nil!.status_code
    Mechanize::Page.new(uri, response, body, code, self)
  end

  # get the history (`Mechanize::History`).
  # the requests mechanize send is recorded in this history.
  # ```
  # agent.history => #<Mechanize::History>
  # ```
  def history : Mechanize::History
    @agent.history
  end

  # add page to history (`Mechanize::History`).
  #
  # if you send request, mechanize calls this method and records page,
  # so you don't need to call this on your own.
  def add_to_history(page)
    history.push(page)
  end

  # Get maximum number of pages allowed in the history.
  # The default setting is 100 pages.
  # ```
  # agent.max_history # => 100
  # ```
  def max_history : Int32
    history.max_size
  end

  # set maximum number of pages allowed in the history.
  # the default value is 100.
  # ```
  # agent.max_history = 150
  # ```
  def max_history=(length : Int32)
    history.max_size = length
  end

  # click link, and transit page.
  #
  # ```
  # page = agent.get("http://example.com")
  # link = page.links.first
  # page2 = agent.click(link)
  # ```
  def click(link : Mechanize::PageContent::Link) : Mechanize::Page
    href = link.href
    get href
  end

  # download page body from given uri.
  # ```
  # # make download.html whose content is http://example.com's html.
  # agent.download("http://example.com", "download.html")
  # ```
  def download(uri : URI | String,
               filename : String,
               headers = ::HTTP::Headers.new,
               params : Hash(String, String | Array(String)) = Hash(String, String).new)
    transact do
      page = get(uri, headers, params)
      case page
      when Mechanize::File
        ::File.write(filename, page.body)
      end
    end
  end

  # Runs given block, then resets the page history as it was before.
  private def transact
    # save the previous history status.
    history_backup = Mechanize::History.new(@agent.history.max_size, @agent.history.array.dup)
    begin
      yield self
    ensure
      # restore the previous history.
      @agent.history = history_backup
    end
  end

  # send POST request from form.
  private def post_form(uri, form, headers) : Mechanize::Page
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
end

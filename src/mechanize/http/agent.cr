require "../cookie"
require "../history"
require "./auth_store"
require "./www_authenticate_parser"

class Mechanize
  module HTTP
    # This class handles web interation mechanize made.
    class Agent
      property request_headers : ::HTTP::Headers
      property context : Mechanize?
      property history : History
      property user_agent : String
      property request_cookies : ::HTTP::Cookies
      getter auth_store : AuthStore
      getter authenticate_methods : Hash(URI, Hash(String, Array(AuthRealm)))
      getter authenticate_parser : WWWAuthenticateParser

      @proxy : ::HTTP::Proxy::Client?

      def initialize(@context : Mechanize? = nil)
        @history = History.new
        @request_headers = ::HTTP::Headers.new
        @context = context
        @request_cookies = ::HTTP::Cookies.new
        @user_agent = ""
        @auth_store = AuthStore.new
        @authenticate_methods = Hash(URI, Hash(String, Array(AuthRealm))).new
        @authenticate_parser = WWWAuthenticateParser.new
      end

      # send http request and return page.
      # This method is called from Mechanize#get, #post and other methods.
      # There's no need to call this method directly.
      def fetch(uri,
                method = :get,
                headers = ::HTTP::Headers.new,
                params = Hash(String, String).new,
                body : String? = nil,
                referer = (current_page unless history.empty?))
        uri = resolve_url(uri, referer)
        set_request_headers(uri, headers)
        set_user_agent
        set_request_referer(referer)
        uri, params = resolve_parameters(uri, method, params)
        client = ::HTTP::Client.new(uri)
        request_auth client, uri
        @proxy.try { |proxy| client.proxy = proxy }
        response = http_request(client, uri, method, params, body)
        body = response.not_nil!.body
        page = response_parse(response, body, uri)
        response_log(response)

        # save cookies
        save_response_cookies(response, uri, page)

        if response && response.status.redirection?
          return follow_redirect(response, headers, page)
        end

        if response && response.status.unauthorized?
          return response_authenticate(response, page, uri, params, referer)
        end

        page
      end

      private def follow_redirect(response, headers, referer)
        redirect_url = response.headers["location"]
        uri = resolve_url(redirect_url, referer)

        Log.debug { "follow redirect to: #{uri}" }

        # Make sure we are not copying over the POST headers from the original request
        headers.delete("Content-MD5")
        headers.delete("Content-Type")
        headers.delete("Content-Length")

        fetch(uri)
      end

      # send http request
      private def http_request(client : ::HTTP::Client,
                               uri : URI,
                               method : Symbol,
                               params : Hash(String, String)?,
                               body : String?) : ::HTTP::Client::Response?
        request_log(uri, method)
        path = uri.path
        path += "?#{uri.query.not_nil!}" if uri.query

        case uri.scheme.not_nil!.downcase
        when "http", "https"
          case method
          when :get
            client.get(path, headers: request_headers)
          when :post
            client.post(path, headers: request_headers, form: params.not_nil!.fetch("value", ""))
          when :put
            client.put(path, headers: request_headers, body: body)
          when :delete
            client.delete(path, headers: request_headers, body: body)
          when :head
            client.head(path, headers: request_headers)
          end
        end
      end

      private def request_auth(client : ::HTTP::Client, uri : URI)
        base_uri = uri.dup
        base_uri.path = "/"
        base_uri.user &&= nil
        base_uri.password &&= nil
        schemes = @authenticate_methods.fetch(base_uri, nil)
        return if schemes.nil?

        if realm = schemes["basic"].find { |r| r.uri == base_uri }
          res = @auth_store.credentials_for uri, realm.realm
          if res
            user, password = res
            client.basic_auth user, password
          end
        end

        # if realm = schemes[:digest].find { |r| r.uri == base_uri } then
        #  request_auth_digest request, uri, realm, base_uri, false
        # elsif realm = schemes[:iis_digest].find { |r| r.uri == base_uri } then
        #  request_auth_digest request, uri, realm, base_uri, true
        # elsif realm = schemes[:basic].find { |r| r.uri == base_uri } then
        #  user, password, = @auth_store.credentials_for uri, realm.realm
        #  request.basic_auth user, password
        # end
      end

      # returns the page now mechanize visiting.
      # ```
      # agent.current_page
      # ```
      def current_page : Page
        @history.last
      end

      # returns the page mechanize previous visited.
      # ```
      # agent.back
      # ```
      def back : Page
        @history.pop
      end

      # Get maximum number of items allowed in the history.  The default setting is 100 pages.
      # ```
      # agent.max_history # => 100
      # ```
      def max_history : Int32
        @history.max_size
      end

      # Set maximum number of items allowed in the history.
      # ```
      # agent.max_history = 1000
      # ```
      def max_history=(length)
        @history.max_size = length
      end

      # set basic auth credentials.
      # ```
      # # set an auth credential with a specific url.
      # agent.add_auth("http://example.com", "username", "password")
      # ```
      def add_auth(uri : String, user : String, pass : String)
        @auth_store.add_auth(uri, user, pass)
      end

      def set_proxy(address : String, port : Int32, user : String? = nil, password : String? = nil)
        @proxy = ::HTTP::Proxy::Client.new(address, port, username: user, password: password)
      end

      private def set_request_headers(uri, headers)
        reset_request_header_cookies
        headers.each do |k, v|
          request_headers[k] = v
        end
        valid_cookies(uri).add_request_headers(request_headers)
      end

      private def set_user_agent
        unless user_agent == ""
          request_headers["User-Agent"] = user_agent
        end
      end

      # Sets a Referer header.
      private def set_request_referer(referer : Page?)
        return unless referer

        request_headers["Referer"] = referer.uri.to_s
      end

      private def resolve_parameters(uri, method, params)
        case method
        when :get
          return uri, nil if params.nil? || params.empty?
          query = URI::Params.encode(params)
          uri.query = query
          return uri, nil
        when :post
          return uri, params
        else
          return uri, params
        end
      end

      private def response_parse(response, body, uri)
        @context.not_nil!.parse(uri, response, body)
      end

      # save cookies from response.
      # parse Set-Cookie meta tag and "Cookie" header.
      private def save_response_cookies(response, uri, page)
        if page.body =~ /Set-Cookie/
          page.css("head meta[http-equiv=\"Set-Cookie\"]").each do |meta|
            cookie = meta["content"].split(";")[0]
            key, value = cookie.split("=")
            cookie = ::HTTP::Cookie.new(name: key, value: value)
            save_cookies(uri, [cookie])
          end
        end
        header_cookies = response.try &.cookies
        if (header_cookies.nil? || header_cookies.try &.empty?)
          return
        else
          save_cookies(uri, header_cookies)
        end
      end

      private def resolve_url(uri, referer) : URI
        if uri.is_a?(URI)
          target_url = uri.dup
        else
          target_url = uri.to_s.strip
          referer_uri = referer.uri if referer
          if target_url.empty?
            raise ArgumentError.new("absolute URL needed")
          end
          # escape non-ascii character
          target_url = target_url.gsub(/[^#{0.chr}-#{126.chr}]/) { |match|
            {% if compare_versions(Crystal::VERSION, "1.1.1") > 0 %}
              URI.encode_path(match)
            {% else %}
              URI.encode(match)
            {% end %}
          }
          target_url = URI.parse(target_url)
        end

        # fill host if host isn't set
        if target_url.host.nil? && referer && referer_uri.try &.host
          target_url.host = referer_uri.not_nil!.host
        end

        # fill scheme if scheme isn't set
        if target_url.relative?
          if referer && referer_uri.try &.scheme
            target_url.scheme = referer_uri.not_nil!.scheme
          else
            target_url.scheme = "http"
          end
        end

        # fill path's slash if there's no slash.
        if target_url.path && (target_url.path.empty? || target_url.path[0] != '/')
          target_url.path = "/#{target_url.path}"
        end
        target_url
      end

      private def response_authenticate(response, page, uri, params, referer) : Page
        www_authenticate = response.headers["www-authenticate"]

        unless www_authenticate = response.headers["www-authenticate"]
          # TODO: raise error
        end

        challenges = @authenticate_parser.parse(www_authenticate)

        unless @auth_store.credentials?(uri, challenges)
          # TODO: raise error
          return page
        end

        if challenge = challenges.find { |c| c.scheme == "Basic" }
          realm = challenge.realm uri
          if realm
            @authenticate_methods[realm.uri] = Hash(String, Array(AuthRealm)).new([] of AuthRealm) unless @authenticate_methods.has_key?(realm.uri)
            existing_realms = @authenticate_methods[realm.uri]["basic"]

            if existing_realms && existing_realms.includes? realm
              # TODO: raise error
            end

            existing_realms << realm
          end
          fetch(uri, headers: request_headers, params: params, referer: referer)
        else
          # TODO: raise error
          raise Exception.new("error")
        end
      end

      # reset request cookie before setting headers.
      private def reset_request_header_cookies
        request_headers.delete("Cookie")
      end

      private def save_cookies(uri, header_cookies)
        host = uri.host
        header_cookies.each do |cookie|
          Log.debug { "saved cookie: #{cookie.name}=#{cookie.value}" }
          cookie.origin = host
          request_cookies << cookie
        end
      end

      # extract valid cookies according to URI
      private def valid_cookies(uri)
        valid_cookies = ::HTTP::Cookies.new
        request_cookies.each do |cookie|
          valid_cookies << cookie if cookie.valid_cookie?(uri)
        end
        valid_cookies
      end

      private def request_log(uri, method)
        Log.debug { "#{method.to_s.upcase}: #{uri}" }

        request_headers.each do |key, values|
          value = values.size == 1 ? values.first : values
          Log.debug { "request-header: #{key} => #{value}" }
        end
      end

      private def response_log(response)
        return unless response

        Log.debug { "status: #{response.version} #{response.status_code} #{response.status_message}" }

        response.headers.each do |key, values|
          value = values.size == 1 ? values.first : values
          Log.debug { "response-header: #{key} => #{value}" }
        end
      end
    end
  end
end

require "uri"
require "http/client"
require "../cookie"
require "../history"

module MechanizeCr
  module HTTP
    class Agent
      property :request_headers, :context
      property history : MechanizeCr::History
      property user_agent : String
      property request_cookies : ::HTTP::Cookies

      def initialize(@context : Mechanize | Nil = nil)
        @history = MechanizeCr::History.new
        @request_headers = ::HTTP::Headers.new
        @context = context
        @request_cookies = ::HTTP::Cookies.new
        @user_agent = ""
      end

      def fetch(uri, method = :get, headers = HTTP::Headers.new, params = Hash(String,String).new,
                referer = (current_page unless history.empty?))
        uri = resolve_url(uri, referer)
        set_request_headers(uri, headers)
        set_user_agent
        uri, params = resolve_parameters(uri, method, params)
        response = http_request(uri, method, params)
        body = response.not_nil!.body
        page = response_parse(response, body, uri)
        # save cookies
        save_response_cookies(response, uri, page)
        page
      end

      def http_request(uri, method, params)
        case uri.scheme.not_nil!.downcase
        when "http", "https" then
          case method
          when :get
            ::HTTP::Client.get(uri, headers: request_headers)
          when :post
            ::HTTP::Client.post(uri, headers: request_headers, form: params.not_nil!.fetch("value", ""))
          end
        end
      end

      def current_page
        @history.last
      end

      def back
        @history.pop
      end

      private def set_request_headers(uri, headers)
        reset_request_header_cookies
        headers.each do |k,v|
          request_headers[k] = v
        end
        valid_cookies(uri).add_request_headers(request_headers)
      end

      private def set_user_agent
        unless user_agent == ""
          request_headers["User-Agent"] = user_agent
        end
      end

      private def resolve_parameters(uri, method, params)
        case method
        when :get
          return uri, nil if params.empty?
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
            cookie =  meta["content"].split(";")[0]
            key,value = cookie.split("=")
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
            URI.encode(match)
          }
          target_url = URI.parse(target_url)
        end

        # fill host if host isn't set
        if  target_url.host.nil? && referer && referer_uri.try &.host
          target_url.host = referer_uri.not_nil!.host
        end
        # fill scheme if scheme isn't set
        if target_url.relative?
          target_url.scheme = "http"
        end
        # fill path's slash if there's no slash.
        if target_url.path && (target_url.path.empty? || target_url.path[0] != '/')
          target_url.path = "/#{target_url.path}"
        end
        target_url
      end

      # reset request cookie before setting headers.
      private def reset_request_header_cookies
        request_headers.delete("Cookie")
      end

      private def save_cookies(uri, header_cookies)
        host = uri.host
        header_cookies.each do |cookie|
          cookie.origin = host
          request_cookies << cookie
        end
      end

      # extract valid cookies according to URI
      private def valid_cookies(uri)
        host = uri.host
        valid_cookies = ::HTTP::Cookies.new
        request_cookies.each do |cookie|
          valid_cookies << cookie if cookie.valid_cookie?(uri)
        end
        valid_cookies
      end
    end
  end
end

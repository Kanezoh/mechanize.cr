require "uri"
require "http/client"

module MechanizeCr
  module HTTP
    class Agent
      property :request_headers, :context, :cookies
      property history : Array(MechanizeCr::Page)
      def initialize(@context : Mechanize | Nil = nil, history = Array(MechanizeCr::Page).new)
        @history = history
        @request_headers = ::HTTP::Headers.new
        @context = context
        @cookies = Hash(String, ::HTTP::Cookies).new
      end

      def fetch(uri, method = :get, headers = HTTP::Headers.new, params = Hash(String,String).new)
        uri = resolve(uri)
        set_request_headers(uri, headers)
        uri, params = resolve_parameters(uri, method, params)
        response = http_request(uri, method, params)
        body = response.not_nil!.body
        page = response_parse(response, body, uri)
        # save cookies
        add_response_cookies(response, uri, page)
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

      private def set_request_headers(uri, headers)
        reset_request_header_cookies
        host = uri.host
        headers.each do |k,v|
          request_headers[k] = v
        end
        if cookies.fetch(host, nil).nil?
          request_headers
        else
          valid_cookies = cookies[host]
          valid_cookies.not_nil!.add_request_headers(request_headers)
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
        @context.not_nil!.parse uri, response, body
      end

      private def add_response_cookies(response, uri, page)
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

      private def resolve(uri) : URI
        if uri.class == URI || uri.to_s.includes?("http")
          URI.parse(uri)
        else
          referer_uri = current_page.uri
          host = referer_uri.host
          scheme = referer_uri.scheme
          uri = "/" + uri unless uri[0] == '/'
          new_uri = URI.new(scheme: scheme, host: host, path: uri)
        end
      end

      private def current_page
        @history.last
      end

      private def reset_request_header_cookies
        request_headers.delete("Cookie")
      end

      private def save_cookies(uri, header_cookies)
        host = uri.host.to_s
        if cookies.fetch(host, ::HTTP::Cookies.new).empty?
          cookies[host] = ::HTTP::Cookies.new
        end
        header_cookies.each do |cookie|
          cookies[host] << cookie
        end
      end
    end
  end
end

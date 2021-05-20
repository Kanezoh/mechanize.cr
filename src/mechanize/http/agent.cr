require "uri"
require "http/client"

module MechanizeCr
  module HTTP
    class Agent
      property :request_headers, :context

      def initialize(@context : Mechanize | Nil = nil)
        @request_headers = ::HTTP::Headers.new
        @context = context
      end

      def fetch(uri, method = :get, headers = HTTP::Headers.new, params = Hash(String,String).new)
        uri = URI.parse(uri)
        set_request_headers(headers)
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
            #client.post(path)
          end
        end
      end

      private def set_request_headers(headers)
        headers.each do |k,v|
          request_headers[k] = v
        end
      end

      private def resolve_parameters(uri, method, params)
        case method
        when :get
          query = URI::Params.encode(params)
          uri.query = query
          return uri, nil
        else
          return uri, params
        end
      end

      private def response_parse(response, body, uri)
        @context.not_nil!.parse uri, response, body
      end

      private def add_response_cookies(response, uri, page)
        #if page.body =~ /Set-Cookie/
        #  page.css("//head/meta[@http-equiv=\"Set-Cookie\"]").each do |meta|
        #    save_cookies(uri, meta["content"])
        #  end
        #end
        header_cookies = response.try &.cookies
        if header_cookies.try &.empty?
          request_headers
        else
          header_cookies.not_nil!.add_request_headers(request_headers)
        end
      end
    end
  end
end

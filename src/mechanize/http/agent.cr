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
        add_request_headers(headers)
        params = hash_to_params(params)
        response = http_request uri, method, params
        body = response.not_nil!.body
        page = response_parse(response, body, uri)
      end

      def http_request(uri, method, params)
        request = ::HTTP::Client.new(uri.host.not_nil!)
        path = compose_path(uri, params)
        case uri.scheme.not_nil!.downcase
        when "http", "https" then
          case method
          when :get
            request.get(path, headers: request_headers)
          end
        end
      end

      private def add_request_headers(headers)
        headers.each do |k,v|
          request_headers[k] = v
        end
      end

      private def hash_to_params(params)
        URI::Params.encode(params)
      end

      private def compose_path(uri, params)
        path = uri.path
        path += "?#{params}" unless params.empty?
        path
      end

      private def response_parse(response, body, uri)
        @context.not_nil!.parse uri, response, body
      end
    end
  end
end

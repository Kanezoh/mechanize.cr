require "uri"
require "http/client"

module MechanizeCr
  module HTTP
    class Agent
      property :request_headers

      def initialize()
        @request_headers = ::HTTP::Headers.new
      end

      def fetch(uri, method = :get, headers = HTTP::Headers.new)
        add_request_headers(headers)
        
        response = http_request uri, method
        puts response.not_nil!.body
      end

      def http_request(uri, method)
        uri = URI.parse(uri)
        request = ::HTTP::Client.new(uri.host.not_nil!)
        case uri.scheme.not_nil!.downcase
        when "http", "https" then
          case method
          when :get
            request.get(uri.path, headers: request_headers)
          end
        end
      end

      private def add_request_headers(headers)
        headers.each do |k,v|
          request_headers[k] = v
        end
      end
    end
  end
end

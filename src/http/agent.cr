require "uri"
require "http/client"

module MechanizeCr
  module HTTP
    class Agent
      def initialize()
      end

      def fetch(uri, method = :get, headers = HTTP::Headers.new)
        response = http_request uri, method, headers
        puts response.not_nil!.body
      end

      def http_request(uri, method, headers)
        uri = URI.parse(uri)
        request = ::HTTP::Client.new(uri.host.not_nil!)
        case uri.scheme.not_nil!.downcase
        when "http", "https" then
          case method
          when :get
            request.get(uri.path, headers: headers)
          end
        end
      end
    end
  end
end

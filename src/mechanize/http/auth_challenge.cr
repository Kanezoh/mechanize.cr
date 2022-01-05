require "./auth_realm"

class Mechanize
  module HTTP
    ##
    # A parsed WWW-Authenticate header

    class AuthChallenge
      property scheme : String?
      property params : String? | Hash(String, String)?
      property raw : String

      def initialize(scheme = nil, params = nil, raw = "")
        @scheme = scheme
        @params = params
        @raw = raw
      end

      def [](param)
        params_value = params
        if params_value.is_a?(Hash)
          params_value[param] # NTLM has a string for params
        else
          nil
        end
      end

      ##
      # Constructs an AuthRealm for this challenge

      def realm(uri)
        target_uri = uri.dup
        target_uri.path = "/"
        case scheme
        when "Basic"
          # raise ArgumentError, "provide uri for Basic authentication" unless uri
          Mechanize::HTTP::AuthRealm.new scheme, target_uri, self["realm"]
        when "Digest"
          Mechanize::HTTP::AuthRealm.new scheme, target_uri, self["realm"]
        else
          # raise Mechanize::Error, "unknown HTTP authentication scheme #{scheme}"
          raise Exception.new("unknown HTTP authentication scheme #{scheme}")
        end
      end

      ##
      # The name of the realm for this challenge

      def realm_name
        params_value = params
        if params_value.is_a?(Hash)
          params_value["realm"] # NTLM has a string for params
        else
          nil
        end
      end

      ##
      # The raw authentication challenge

      # alias to_s raw

    end
  end
end

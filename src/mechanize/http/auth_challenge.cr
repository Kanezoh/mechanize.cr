class Mechanize
  module HTTP
    ##
    # A parsed WWW-Authenticate header

    class AuthChallenge
      property scheme : String?
      property params : String?

      def initialize(scheme = nil, params = nil)
      end

      # def [] param
      #  params[param]
      # end

      ##
      # Constructs an AuthRealm for this challenge

      def realm(uri)
        case scheme
        when "Basic"
          # raise ArgumentError, "provide uri for Basic authentication" unless uri
          Mechanize::HTTP::AuthRealm.new scheme, uri + '/', self["realm"]
        when "Digest"
          Mechanize::HTTP::AuthRealm.new scheme, uri + '/', self["realm"]
        else
          # raise Mechanize::Error, "unknown HTTP authentication scheme #{scheme}"
        end
      end

      ##
      # The name of the realm for this challenge

      def realm_name
        params["realm"] if Hash === params # NTLM has a string for params
      end

      ##
      # The raw authentication challenge

      # alias to_s raw

    end
  end
end

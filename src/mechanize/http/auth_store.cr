class Mechanize
  module HTTP
    # This class store info for HTTP Authentication.
    class AuthStore
      getter auth_accounts : Hash(URI, Hash(String, Array(String)))

      def initialize
        @auth_accounts = Hash(URI, Hash(String, Array(String))).new
      end

      def add_auth(uri : String | URI, user : String, pass : String, realm : String? = nil, domain : String? = nil)
        unless uri.is_a?(URI)
          uri = URI.parse(uri)
        end
        uri.path = "/"
        uri.user = nil
        uri.password = nil
        realm = "" if realm.nil?
        domain = "" if domain.nil?

        realm_hash = {realm => [user, pass, domain]}
        if auth_accounts.has_key?(uri)
          auth_accounts[uri].merge!(realm_hash)
        else
          auth_accounts[uri] = realm_hash
        end
      end

      ##
      # Returns true if credentials exist for the +challenges+ from the server at
      # +uri+.

      def credentials?(uri, challenges)
        challenges.any? do |challenge|
          credentials_for uri, challenge.realm_name
        end
      end

      # Retrieves credentials for +realm+ on the server at +uri+.
      def credentials_for(uri : String | URI, realm : String?) : Array(String)?
        unless uri.is_a?(URI)
          uri = URI.parse(uri)
        end
        uri.path = "/"
        uri.user = nil
        uri.password = nil
        realm = "" if realm.nil?

        realms = auth_accounts.fetch(uri, nil)
        return nil if realms.nil?

        realms.fetch(realm, nil) || realms.fetch("", nil)
      end
    end
  end
end

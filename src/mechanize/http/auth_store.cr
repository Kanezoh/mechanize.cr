class Mechanize
  module HTTP
    # This class store info for HTTP Authentication.
    class AuthStore
      getter auth_accounts : Hash(URI, Hash(String, Array(String)))

      def initialize
        @auth_accounts = Hash(URI, Hash(String, Array(String))).new
      end

      # set an auth credential with a specific url.
      def add_auth(uri : String | URI, user : String, pass : String, realm : String? = nil, domain : String? = nil)
        target_uri = uri.dup
        unless uri.is_a?(URI)
          target_uri = URI.parse(uri)
        end
        target_uri = target_uri.as(URI)
        target_uri.path = "/"
        target_uri.user = nil
        target_uri.password = nil
        realm = "" if realm.nil?
        domain = "" if domain.nil?

        realm_hash = {realm => [user, pass, domain]}
        if auth_accounts.has_key?(target_uri)
          auth_accounts[target_uri].merge!(realm_hash)
        else
          auth_accounts[target_uri] = realm_hash
        end
      end

      # Returns true if credentials exist for the +challenges+ from the server at
      # +uri+.

      def credentials?(uri, challenges) : Bool
        challenges.any? do |challenge|
          credentials_for uri, challenge.realm_name
        end
      end

      # Retrieves credentials for +realm+ on the server at +uri+.
      def credentials_for(uri : String | URI, realm : String?) : Array(String)?
        target_uri = uri.dup
        unless uri.is_a?(URI)
          target_uri = URI.parse(uri)
        end
        target_uri = target_uri.as(URI)
        target_uri.path = "/"
        target_uri.user = nil
        target_uri.password = nil
        realm = "" if realm.nil?

        realms = auth_accounts.fetch(target_uri, nil)
        return nil if realms.nil?

        realms.fetch(realm, nil) || realms.fetch("", nil)
      end
    end
  end
end

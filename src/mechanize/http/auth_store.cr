class Mechanize
  module HTTP
    # This class store info for HTTP Authentication.
    class AuthStore
      getter auth_accounts : Hash(URI, Hash(String, Array(String?)))

      def initialize
        @auth_accounts = Hash(URI, Hash(String, Array(String?))).new
      end

      def add_auth(uri : String | URI, user : String, pass : String, realm : String? = nil, domain : String? = nil)
        unless uri.is_a?(URI)
          uri = URI.new(uri)
        end
        # uri += '/'
        uri.user = nil
        uri.password = nil
        if realm.nil?
          realm = ""
        end
        realm_hash = {realm => [user, pass, domain]}
        auth_accounts[uri] = realm_hash
      end

      # Retrieves credentials for +realm+ on the server at +uri+.
      def credentials_for(uri : String | URI, realm : String) : Array(String?)
        unless uri.is_a?(URI)
          uri = URI.new(uri)
        end
        # uri += '/'
        uri.user = nil
        uri.password = nil

        realms = auth_accounts[uri]

        realms[realm]
      end
    end
  end
end

class Mechanize
  module HTTP
    # This class store info for HTTP Authentication.
    class AuthStore
      getter auth_accounts : Hash(URI, Tuple(String, String))
      def initialize
        @auth_accounts = Hash(URI, Tuple(String, String)).new
      end

      def add_auth(uri, user, pass)
        unless uri.is_a?(URI)
          uri = URI.new(uri) 
        end
        #uri += '/'
        uri.user = nil
        uri.password = nil

        auth_accounts[uri] = {user, pass}
      end  ##

      # Retrieves credentials for +realm+ on the server at +uri+.
      def credentials_for(uri, realm) : Tuple(String)
        unless uri.is_a?(URI)
          uri = URI.new(uri) 
        end
        #uri += '/'
        uri.user = nil
        uri.password = nil
        
        auth_accounts[uri]
      end
    end
  end
end

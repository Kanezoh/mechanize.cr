require "string_scanner"
require "./auth_challenge"

##
# Parses the WWW-Authenticate HTTP header into separate challenges.

class Mechanize
  module HTTP
    class WWWAuthenticateParser
      property scanner : StringScanner

      # Creates a new header parser for WWW-Authenticate headers

      def initialize
        @scanner = StringScanner.new("")
      end

      # Parsers the header.  Returns an Array of challenges as strings

      def parse(www_authenticate : String)
        challenges = [] of Mechanize::HTTP::AuthChallenge
        @scanner = StringScanner.new(www_authenticate)

        loop do
          break if scanner.eos?
          start = scanner.offset
          challenge = Mechanize::HTTP::AuthChallenge.new

          scheme = auth_scheme

          if scheme == "Negotiate"
            scan_comma_spaces
          end

          break unless scheme
          challenge.scheme = scheme

          space = spaces

          if scheme == "NTLM"
            if space
              challenge.params = scanner.scan(/.*/)
            end

            # challenge.raw = www_authenticate[start, @scanner.pos]
            challenges << challenge
            next
          else
            scheme = scheme.capitalize
          end

          next unless space
          params = Hash(String, String).new

          loop do
            offset = scanner.offset
            param = auth_param
            if param
              name, value = param
              name = name.downcase if name =~ /^realm$/i
              params[name] = value
            else
              challenge.params = params
              challenges << challenge

              if scanner.eos?
                # challenge.raw = www_authenticate[start, scanner.offset]
                break
              end

              scanner.offset = offset # rewind
              # challenge.raw = www_authenticate[start, scanner.offset].sub(/(,+)? *$/, "")
              challenge = nil # a token should be next, new challenge
              break
            end

            spaces

            scanner.scan(/(, *)+/)
          end
        end

        challenges
      end

      # scans a comma followed by spaces
      # needed for Negotiation, NTLM

      def scan_comma_spaces
        scanner.scan(/, +/)
      end

      #   token = 1*<any CHAR except CTLs or separators>
      #
      # Parses a token

      def token
        scanner.scan(/[^\000-\037\177()<>@,;:\\"\/\[\]?={} ]+/)
      end

      def auth_scheme
        token
      end

      ##
      #   1*SP
      #
      # Parses spaces

      def spaces
        scanner.scan(/ +/)
      end

      #   auth-param = token "=" ( token | quoted-string )
      #
      # Parses an auth parameter

      def auth_param : Array(String)?
        return nil unless name = token
        return nil unless scanner.scan(/ *= */)

        value = if scanner.peek(1) == "\""
                  quoted_string
                else
                  token
                end

        return nil unless value

        return [name, value]
      end

      ##
      #   quoted-string = ( <"> *(qdtext | quoted-pair ) <"> )
      #   qdtext        = <any TEXT except <">>
      #   quoted-pair   = "\" CHAR
      #
      # For TEXT, the rules of RFC 2047 are ignored.

      def quoted_string
        return nil unless @scanner.scan(/"/)

        text = String.new

        loop do
          chunk = scanner.scan(/[\r\n \t\x21\x23-\x7e\x{0080}-\x{00ff}]+/) # not " which is \x22

          if chunk
            text += chunk

            text += (scanner.scan(/./) || "") if chunk.ends_with?("\\") && "\"" == scanner.peek(1)
          else
            if "\"" == scanner.peek(1)
              scanner.scan(/./)
              break
            else
              return nil
            end
          end
        end

        text
      end
    end
  end
end

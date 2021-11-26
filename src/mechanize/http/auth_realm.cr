# This class represents realm attribute of www-authenticate header.
class Mechanize::HTTP::AuthRealm
  getter scheme : String
  getter uri : URI
  getter realm : String

  def initialize(scheme, uri, realm)
    @scheme = scheme
    @uri = uri
    @realm = realm if realm
  end

  def ==(other)
    self.class === other and
    @scheme == other.scheme and
    @uri == other.uri and
    @realm == other.realm
  end

  def hash # :nodoc:
    [@scheme, @uri, @realm].hash
  end

  def inspect # :nodoc:
    "#<AuthRealm %s %p \"%s\">" % [@scheme, @uri, @realm]
  end
end

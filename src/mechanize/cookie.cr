# TODO: want to add methods with safe way like Ruby's refinement.

# open HTTP::Cookie class to add origin property.
# origin property represents the origin of the resource.
# if cookie's domain attribute isn't designated,
# this property is used to send cookies to same origin resource.
class ::HTTP::Cookie
  property origin : String?
  def initialize(name : String, value : String, @path : String? = nil,
    @expires : Time? = nil, @domain : String? = nil,
    @secure : Bool = false, @http_only : Bool = false,
    @samesite : SameSite? = nil, @extension : String? = nil,
    @origin : String? = nil)
    validate_name(name)
    @name = name
    validate_value(value)
    @value = value
    @origin = origin
  end

  def valid_cookie?(uri)
    host = uri.host
    if path
      bool = uri.path.try &.=~(/^#{path}.*/)
      return false if bool.nil?
    end

    if secure
      return false if uri.scheme == "http"
    end

    if domain
      host.try &.=~(/.*#{domain.try &.gsub(".", "\.")}$/)
    else
      origin == host
    end
  end
end

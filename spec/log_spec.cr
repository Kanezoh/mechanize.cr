require "./spec_helper"
require "log/spec"

describe "Mechanize logging" do
  it "emit logs" do
    Log.capture("mechanize") do |logs|
      agent = Mechanize.new
      agent.user_agent = "Firefox"
      page = agent.get("http://example.com/form")

      logs.check(:debug, "GET: http://example.com/form")
      logs.check(:debug, "request-header: User-Agent => Firefox")
      logs.check(:debug, "status: HTTP/1.1 200 OK")
      logs.check(:debug, "response-header: Content-length => 291")
      logs.check(:debug, "response-header: Connection => close")
    end
  end
end

require "./spec_helper"
require "./server.cr"
#WebMock.stub(:get, "http://auth.example.com/")
#  .with(headers: {"Authorization" => "Basic #{Base64.strict_encode("user:pass").chomp}"})
#  .to_return(status: 200)
#
#WebMock.stub(:get, "http://auth.example.com/")
#  .to_return(status: 401, headers: {"WWW-Authenticate" => "Basic realm=\"Access to the staging site\", charset=\"UTF-8\""})

describe "Mechanize HTTP Authentication test" do
   WebMock.allow_net_connect = true
   it "auth" do
    agent = Mechanize.new
    page = agent.get("#{TEST_SERVER_URL}/secret")
    p page.body
    WebMock.allow_net_connect = false
   end
end

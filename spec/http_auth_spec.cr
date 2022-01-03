require "./spec_helper"

WebMock.stub(:get, "http://auth.example.com/")
  .with(headers: {"Authorization" => "Basic #{Base64.strict_encode("user:pass").chomp}"})
  .to_return(status: 200)

WebMock.stub(:get, "http://auth.example.com/")
  .to_return(status: 401, headers: {"WWW-Authenticate" => "Basic realm=\"Access to the staging site\", charset=\"UTF-8\""})

describe "Mechanize HTTP Authentication test" do
  # it "auth" do
  #  agent = Mechanize.new
  #  agent.get("http://auth.example.com/")
  # end
end

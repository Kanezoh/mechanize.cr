require "./spec_helper"

WebMock.stub(:get, "example.com/cookies1").to_return(headers: {"Set-Cookie" => "id=123"})
WebMock.stub(:get, "example.com/cookies1_domain").to_return(headers: {"Set-Cookie" => "id=123; Domain=example.com"})
WebMock.stub(:get, "example.com/cookies2").to_return(headers: {"Set-Cookie" => "name=kanezoh"})
WebMock.stub(:get, "example.com/cookies3").to_return(headers: {"Set-Cookie" => "id=456"})
WebMock.stub(:get, "www.example.com").to_return()
WebMock.stub(:get, "example.com/meta_cookie").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
    <meta http-equiv='Set-Cookie' content='id=123;SameSite=None;Secure'>
  </head>
  <body>
  </body>
</html>
BODY
)

describe "Mechanize Cookie test" do
  it "can receive and send cookie" do
    agent = Mechanize.new
    # receive cookies
    agent.get("http://example.com/cookies1")
    # send cookies
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123"
  end

  it "updates cookie value if key is same" do
    agent = Mechanize.new
    agent.get("http://example.com/cookies1")
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123"
    agent.get("http://example.com/cookies3")
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=456"
  end

  it "can receive and send multiple cookies" do
    agent = Mechanize.new
    # receive cookies1
    agent.get("http://example.com/cookies1")
    # receive cookies2
    agent.get("http://example.com/cookies2")
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123; name=kanezoh"
  end

  it "can get cookie from meta head" do
    agent = Mechanize.new
    agent.get("http://example.com/meta_cookie")
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123"
  end

  it "doesn't send cookies to another domain" do
    agent = Mechanize.new
    agent.get("http://example.com/cookies1")
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123"
    agent.get("http://another_domain.com/")
    agent.request_headers.has_key?("Cookie").should eq false
  end

  it "sends cookie to subdomain if domain attribute is set" do
    agent = Mechanize.new
    agent.get("http://example.com/cookies1")
    agent.get("http://www.example.com/")
    agent.request_headers.has_key?("Cookie").should eq false

    agent.get("http://example.com/cookies1_domain")
    agent.get("http://www.example.com/")
    agent.request_headers.has_key?("Cookie").should eq true
  end
end

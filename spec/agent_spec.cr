require "./spec_helper"
WebMock.stub(:get, "example.com/cookies1").to_return(headers: {"Set-Cookie" => "id=123"})
WebMock.stub(:get, "example.com/cookies2").to_return(headers: {"Set-Cookie" => "name=kanezoh"})
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

describe "Mechanize Agent test" do
  it "can fill and submit form" do
    agent = Mechanize.new
    page = agent.get("http://example.com/form")
    form = page.forms[0]
    form.field_with("name").value = "foo"
    form.field_with("email").value = "bar"
    page = agent.submit(form)
    page.not_nil!.code.should eq 200
    page.not_nil!.body.should eq "success"
  end

  it "can receive and send cookie" do
    agent = Mechanize.new
    # receive cookies
    agent.get("http://example.com/cookies1")
    # send cookies
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123"
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

  it "can save history" do
    agent = Mechanize.new
    agent.get("http://example.com/")
    agent.history.size.should eq 1
    agent.history.last.title.should eq ""
    agent.get("http://example.com/form")
    agent.history.size.should eq 2
    agent.history.last.title.should eq "page_title"
  end

  it "can back previous page" do
    agent = Mechanize.new
    agent.get("http://example.com/")
    agent.get("http://example.com/form")
    agent.current_page.title.should eq "page_title"
    agent.back
    agent.current_page.title.should eq ""
  end
end

require "./spec_helper"
WebMock.stub(:get, "example.com/")
WebMock.stub(:get, "another_domain.com/")
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
WebMock.stub(:get, "html_example.com").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="text" name="name">
      <input type="text" name="email">
      <input type="submit" value="">
    </form>
  </body>
</html>
BODY
)
WebMock.stub(:post, "http://html_example.com/post_path").
         with(body: "name=foo&email=bar", headers: {"Content-Type" => "application/x-www-form-urlencoded"}).
         to_return(body: "success")

describe "Mechanize Agent test" do
  it "fill and submit form" do
    agent = Mechanize.new
    page = agent.get("http://html_example.com/")
    form = page.forms[0]
    form.field_with("name").value = "foo"
    form.field_with("email").value = "bar"
    page = agent.submit(form)
    page.not_nil!.code.should eq 200
    page.not_nil!.body.should eq "success"
  end

  it "receive and send cookie" do
    agent = Mechanize.new
    # receive cookies
    agent.get("http://example.com/cookies1")
    # send cookies
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123"
  end

  it "receive and send multiple cookies" do
    agent = Mechanize.new
    # receive cookies1
    agent.get("http://example.com/cookies1")
    # receive cookies2
    agent.get("http://example.com/cookies2")
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123; name=kanezoh"
  end

  it "get cookie from meta head" do
    agent = Mechanize.new
    agent.get("http://example.com/meta_cookie")
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123"
  end

  it "don't send cookies to another domain" do
    agent = Mechanize.new
    agent.get("http://example.com/cookies1")
    agent.get("http://example.com/")
    agent.request_headers["Cookie"].should eq "id=123"
    agent.get("http://another_domain.com/")
    agent.request_headers.has_key?("Cookie").should eq false
  end
end

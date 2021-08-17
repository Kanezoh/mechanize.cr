require "./spec_helper"
WebMock.stub(:get, "http://example.com/?foo=bar&foo1=bar2")
WebMock.stub(:post, "http://example.com/post")
  .with(body: "email=foobar", headers: {"Content-Type" => "application/x-www-form-urlencoded"})
  .to_return(body: "success")
WebMock.stub(:get, "example.com/%E3%81%82%E3%81%82%E3%81%82")

describe "Mechanize HTTP test" do
  it "simple GET" do
    agent = Mechanize.new
    uri = "http://example.com/"
    page = agent.get(uri)
    page.code.should eq 200
    page.uri.to_s.should eq uri
  end

  it "GET with query parameter" do
    agent = Mechanize.new
    params = {"foo" => "bar", "foo1" => "bar2"}
    uri = "http://example.com/"
    page = agent.get(uri, params: params)
    page.code.should eq 200
    page.uri.to_s.should eq "http://example.com/?foo=bar&foo1=bar2"
  end

  it "GET with query parameter as URL string" do
    agent = Mechanize.new
    uri = "http://example.com/?foo=bar&foo1=bar2"
    page = agent.get(uri)
    page.code.should eq 200
    page.uri.to_s.should eq uri
  end

  it "can escape non-ascii character" do
    agent = Mechanize.new
    page = agent.get("http://example.com/あああ")
    page.uri.to_s.should eq "http://example.com/%E3%81%82%E3%81%82%E3%81%82"
  end

  it "set custom request headers" do
    agent = Mechanize.new
    uri = "http://example.com/"
    headers = HTTP::Headers{"Foo" => "Bar"}
    agent.request_headers.empty?.should eq true
    page = agent.get(uri, headers: headers)
    agent.request_headers.empty?.should eq false
    agent.request_headers["Foo"].should eq "Bar"
  end

  it "simple POST" do
    agent = Mechanize.new
    query = {"email" => "foobar"}
    page = agent.post("http://example.com/post", query: query)
    page.body.should eq "success"
    page.code.should eq 200
  end

  it "can set user agent" do
    agent = Mechanize.new
    mac_chrome_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"
    agent.user_agent = mac_chrome_agent
    page = agent.get("http://example.com/")
    agent.request_headers["User-Agent"].should eq mac_chrome_agent
  end
end

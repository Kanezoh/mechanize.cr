require "./spec_helper"
WebMock.stub(:get, "http://example.com/?foo=bar&foo1=bar2")
WebMock.stub(:post, "http://example.com/post")
  .with(body: "email=foobar", headers: {"Content-Type" => "application/x-www-form-urlencoded"})
  .to_return(body: "success")
WebMock.stub(:get, "example.com/%E3%81%82%E3%81%82%E3%81%82")
WebMock.stub(:get, "https://example.com/")
WebMock.stub(:get, "https://example.com/post")
WebMock.stub(:put, "http://example.com/put")
  .with(body: "hello")
  .to_return(body: "success")
WebMock.stub(:delete, "http://example.com/delete")
  .with(body: "hello")
  .to_return(body: "success")
WebMock.stub(:head, "http://example.com/head")

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

  it "simple POST" do
    agent = Mechanize.new
    query = {"email" => "foobar"}
    page = agent.post("http://example.com/post", query: query)
    page.body.should eq "success"
    page.code.should eq 200
  end

  it "PUT" do
    agent = Mechanize.new
    page = agent.put("http://example.com/put", body: "hello")
    page.body.should eq "success"
    page.code.should eq 200
  end

  it "DELETE" do
    agent = Mechanize.new
    page = agent.delete("http://example.com/delete", body: "hello")
    page.body.should eq "success"
    page.code.should eq 200
  end

  it "HEAD" do
    agent = Mechanize.new
    page = agent.head("http://example.com/head")
    page.body.should eq ""
    page.code.should eq 200
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

  it "can set user agent" do
    agent = Mechanize.new
    mac_chrome_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"
    agent.user_agent = mac_chrome_agent
    page = agent.get("http://example.com/")
    agent.request_headers["User-Agent"].should eq mac_chrome_agent
  end

  it "can complete uri when uri is relative" do
    agent = Mechanize.new
    agent.get("https://example.com/")
    page = agent.get("/post")
    page.uri.to_s.should eq "https://example.com/post"
  end
end

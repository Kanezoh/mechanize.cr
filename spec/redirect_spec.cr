require "./spec_helper"

WebMock.stub(:get, "http://example.com/redirect").to_return(body: "success")

WebMock.stub(:post, "http://example.com/post")
  .with(body: "email=foobar", headers: {"Content-Type" => "application/x-www-form-urlencoded"})
  .to_return(status: 302, body: "redirect", headers: {"Location" => "http://example.com/redirect"})

describe "Mechanize redirect test" do
  it "redirect" do
    agent = Mechanize.new
    query = {"email" => "foobar"}
    page = agent.post("http://example.com/post", query: query)
    page.body.should eq("success")
    page.code.should eq(200)
  end
end

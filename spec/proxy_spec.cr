require "./spec_helper"

WebMock.stub(:get, "http://example.com/with_proxy").to_return(body: "success")

describe "Mechanize proxy test" do
  it "set proxy" do
    with_proxy_server do |host, port, wants_close|
      agent = Mechanize.new
      agent.set_proxy("127.0.0.1", 8080)
      page = agent.get("http://example.com/with_proxy")
      page.body.should eq("success")
      page.code.should eq(200)
    ensure
      wants_close.send(nil)
    end
  end
end

require "./spec_helper"
WebMock.stub(:get, "example.com")
WebMock.stub(:get, "fail_example.com").to_return(status: 500)
WebMock.stub(:get, "body_example.com").to_return(body: "hello")
WebMock.stub(:get, "html_example.com").to_return(body: 
<<-BODY
<html>
  <meta>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path">
      <input type="text" name="name">
      <input type="text" name="email">
      <input type="submit" value="">
    </form>
  </body>
</html>
BODY
)

describe "Mechanize Page test" do
  it "return status code of request" do
    agent = Mechanize.new
    page = agent.get("http://example.com/")
    page.code.should eq 200
    page = agent.get("http://fail_example.com")
    page.code.should eq 500
  end

  it "return request body" do
    agent = Mechanize.new
    page = agent.get("http://example.com/")
    page.body.should eq ""
    page = agent.get("http://body_example.com")
    page.body.should eq "hello"
  end

  it "return page title" do
    agent = Mechanize.new
    page = agent.get("http://example.com/")
    page.title.should eq ""
    page = agent.get("http://html_example.com")
    page.title.should eq "page_title"
  end

  it "return page forms" do
    agent = Mechanize.new
    page = agent.get("http://html_example.com")
    page.forms.size.should eq 1
    page.forms.first.action.should eq "post_path"
  end
end

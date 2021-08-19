require "spec"
require "webmock"
require "../src/mechanize"

WebMock.stub(:get, "example.com")
WebMock.stub(:get, "fail_example.com").to_return(status: 500)
WebMock.stub(:get, "body_example.com").to_return(body: "hello")
WebMock.stub(:get, "another_domain.com/")

WebMock.stub(:get, "example.com/form").to_return(body: <<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="text" name="name">
      <input type="text" name="email">
      <input type="submit" name="commit" value="submit">
    </form>
  </body>
</html>
BODY
)

WebMock.stub(:get, "example.com/link").to_return(body: <<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <a href="http://example.com/">link text</a>
  </body>
</html>
BODY
)

WebMock.stub(:post, "example.com/post_path")
  .with(body: "name=foo&email=bar", headers: {"Content-Type" => "application/x-www-form-urlencoded"})
  .to_return(body: "success")

WebMock.stub(:post, "example.com/post_path")
  .with(body: "name=foo&email=bar&commit=submit", headers: {"Content-Type" => "application/x-www-form-urlencoded"})
  .to_return(body: "success with button")

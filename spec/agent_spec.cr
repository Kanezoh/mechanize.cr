require "./spec_helper"
WebMock.stub(:get, "html_example.com").to_return(body: 
<<-BODY
<html>
  <meta>
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
  agent = Mechanize.new
  page = agent.get("http://html_example.com/")
  form = page.forms[0]
  form.field_with("name").value = "foo"
  form.field_with("email").value = "bar"
  page = agent.submit(form)
  page.not_nil!.code.should eq 200
  page.not_nil!.body.should eq "success"
end

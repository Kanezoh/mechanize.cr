require "./spec_helper"

WebMock.stub(:get, "example.com/check_form").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="text" name="name">
      <input type="text" name="email">
      <input type="checkbox" id="remember_me" name="remember_me" checked>
      <input type="radio" id="contactChoice1" name="contact" value="email">
      <input type="radio" id="contactChoice2" name="contact" value="phone">
      <input type="radio" id="contactChoice3" name="contact" value="mail">
    </form>
  </body>
</html>
BODY
)

describe "Mechanize Form test" do
  agent = Mechanize.new
  uri = "http://example.com/check_form"
  page = agent.get(uri)
  form = page.forms.first

  it "returns form attribute" do
    form.action.should eq "post_path"
    form.method.should eq "POST"
    form.enctype.should eq "application/x-www-form-urlencoded"
    form.name.should eq "sample_form"
  end

  it "includes fields" do
    form.fields.size.should eq 2
  end
end

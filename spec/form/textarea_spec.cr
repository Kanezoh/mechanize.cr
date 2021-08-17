require "../spec_helper"

WebMock.stub(:get, "example.com/form/textarea").to_return(body: <<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="textarea" name="input_textarea">
      <textarea name="textarea_tag">
    </form>
  </body>
</html>
BODY
)

describe "Form Fields CheckBox" do
  agent = Mechanize.new
  page = agent.get("http://example.com/form/textarea")
  form = page.forms[0]

  it "returns textareas" do
    form.textareas.size.should eq 2
  end
end

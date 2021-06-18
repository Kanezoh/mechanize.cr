require "../spec_helper"

WebMock.stub(:get, "example.com/form/fields").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="text" name="name">
      <input type="text" name="email">
    </form>
  </body>
</html>
BODY
)

describe "Form Fields" do
  agent = Mechanize.new
  page = agent.get("http://example.com/form/fields")
  form = page.forms[0]
  it "returns field attribute" do
    field = form.fields.first
    field.type.should eq "text"
    field.name.should eq "name"
  end
end

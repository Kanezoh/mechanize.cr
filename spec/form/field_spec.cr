require "../spec_helper"

WebMock.stub(:get, "example.com/form/fields").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="text" name="name" value="kanezoh">
      <input type="text" name="name" value="dareda">
      <input type="text" name="email" class="emailClass" id="emailID">
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
    field.value.should eq "kanezoh"
    field.raw_value.should eq "kanezoh"
  end

  it "returns DOM id and class" do
    field = form.fields.first
    # dom_id and class returns empty string if there are no id, class
    field.dom_id.should eq ""
    field.dom_class.should eq ""
    field = form.fields[2]
    field.dom_id.should eq "emailID"
    field.dom_class.should eq "emailClass"
  end

  it "can be found by field_with method" do
    name_field = form.field_with("name")
    name_field.name.should eq "name"
  end

  it "can be found by fields_with method" do
    name_fields = form.fields_with("name")
    name_fields.size.should eq 2
    name_fields[0].name.should eq "name"
  end
end

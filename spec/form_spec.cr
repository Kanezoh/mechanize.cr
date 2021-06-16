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

  it "retrun form attribute" do
    form.action.should eq "post_path"
    form.method.should eq "POST"
    form.enctype.should eq "application/x-www-form-urlencoded"
    form.name.should eq "sample_form"
  end

  it "includes fields" do
    form.fields.size.should eq 2
  end

  context "Form Fields" do
    it "returns field attribute" do
      field = form.fields.first
      field.type.should eq "text"
      field.name.should eq "name"
    end
  end

  context "Form Fields CheckBox" do
    checkbox = form.checkboxes.first
    it "returns checkbox status" do
      checkbox.checked?.should eq true
    end
    it "can change check status" do
      checkbox.checked?.should eq true
      checkbox.uncheck
      checkbox.checked?.should eq false
      checkbox.check
      checkbox.checked?.should eq true
      # #click reverses check status 
      checkbox.click
      checkbox.checked?.should eq false
      checkbox.click
      checkbox.checked?.should eq true
    end
    it "doesn't include request data if checkbox isn't checked" do
      form.request_data.should contain("remember_me=on")
      checkbox.uncheck
      form.request_data.should_not contain("remember_me=")
    end
  end
end

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

describe "Mechanize Form test" do
  agent = Mechanize.new
  uri = "http://html_example.com/"
  page = agent.get(uri)
  form = page.forms.first
  it "retrun form attribute" do
    form.action.should eq "post_path"
    form.method.should eq "POST"
    form.enctype.should eq "application/x-www-form-urlencoded"
    form.name.should eq "sample_form"
  end

  context "Form Fields" do
    it "forms include fields" do
      form.fields.size.should eq 3
    end
    it "return field attribute" do
      field = form.fields.first
      field.type.should eq "text"
      field.name.should eq "name"
    end
  end
end

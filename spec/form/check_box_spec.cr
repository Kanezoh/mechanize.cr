require "../spec_helper"

WebMock.stub(:get, "example.com/form/check_box").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="checkbox" class="some_checkbox" id="remember_me" name="remember_me" checked>
      <input type="checkbox" class="some_checkbox" id="forget_me" name="forget_me">
    </form>
  </body>
</html>
BODY
)

describe "Form Fields CheckBox" do
  agent = Mechanize.new
  page = agent.get("http://example.com/form/check_box")
  form = page.forms[0]

  it "returns checkbox status" do
    checkbox = form.checkboxes.first
    checkbox.checked?.should eq true
  end

  it "can change check status" do
    checkbox = form.checkboxes.first
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

  it "doesn't included in request data if checkbox isn't checked" do
    checkbox = form.checkboxes.first
    form.request_data.should contain("remember_me=on")
    checkbox.uncheck
    form.request_data.should_not contain("remember_me=")
  end

  it "can be found by checkbox_with method" do
    checkbox = form.checkbox_with("remember_me")
    checkbox.name.should eq "remember_me"
  end

  it "can be found by checkboxes_with method, argument type: Hash" do
    checkboxes = form.checkboxes_with({"class" => "some_checkbox"})
    checkboxes.size.should eq 2
    checkboxes[0].name.should eq "remember_me"
    checkboxes[1].name.should eq "forget_me"
  end

  it "can be found by checkboxes_with method, argument type: NamedTuple" do
    checkboxes = form.checkboxes_with({class: "some_checkbox"})
    checkboxes.size.should eq 2
    checkboxes[0].name.should eq "remember_me"
    checkboxes[1].name.should eq "forget_me"
  end
end

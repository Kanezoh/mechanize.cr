require "../spec_helper"

WebMock.stub(:get, "example.com/form/check_box").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="checkbox" id="remember_me" name="remember_me" checked>
    </form>
  </body>
</html>
BODY
)

describe "Form Fields CheckBox" do
  agent = Mechanize.new
  page = agent.get("http://example.com/form/check_box")
  form = page.forms[0]
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

  it "doesn't included in request data if checkbox isn't checked" do
    form.request_data.should contain("remember_me=on")
    checkbox.uncheck
    form.request_data.should_not contain("remember_me=")
  end
end

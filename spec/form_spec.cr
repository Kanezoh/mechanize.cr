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

  context "Form Fields RadioButton" do
    radiobuttons = form.radiobuttons
    radiobuttons.size.should eq 3
    it "returns radiobutton check status" do
      radiobuttons.map(&.checked?).should eq [false,false,false]  
    end
    it "can change check status" do
      radiobutton = radiobuttons.first
      radiobutton.checked?.should eq false
      radiobutton.check
      radiobutton.checked?.should eq true
      radiobutton.uncheck
      radiobutton.checked?.should eq false
      # #click reverses check status 
      radiobutton.click
      radiobutton.checked?.should eq true
      radiobutton.click
      radiobutton.checked?.should eq false
    end
    it "check status is exclusive" do
      radiobuttons[0].check
      radiobuttons[0].checked.should eq true
      radiobuttons[1].checked.should eq false
      radiobuttons[1].check
      radiobuttons[1].checked.should eq true
      radiobuttons[0].checked.should eq false
    end
  end
end

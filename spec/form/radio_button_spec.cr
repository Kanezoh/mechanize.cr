require "../spec_helper.cr"

WebMock.stub(:get, "example.com/form/radio_button").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <input type="radio" id="contactChoice1" name="contact" value="email">
      <input type="radio" id="contactChoice2" name="contact" value="phone">
      <input type="radio" id="contactChoice3" name="contact" value="mail">
    </form>
  </body>
</html>
BODY
)

describe "Form Fields RadioButton" do
  agent = Mechanize.new
  page = agent.get("http://example.com/form/radio_button")
  form = page.forms[0]

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

  it "doesn't included in request data if checkbox isn't checked" do
    radiobuttons[0].check
    form.request_data.should contain "contact=email"
    radiobuttons[0].uncheck
    form.request_data.should_not contain "contact"
  end

  it "can be found by radiobutton_with method" do
    radiobutton = form.radiobutton_with("contact")
    radiobutton.value.should eq "email"
  end

  it "can be found by radiobuttons_with method" do
    radiobuttons = form.radiobuttons_with("contact")
    radiobuttons.size.should eq 3
    radiobuttons[0].value.should eq "email"
    radiobuttons[1].value.should eq "phone"
    radiobuttons[2].value.should eq "mail"
  end
end

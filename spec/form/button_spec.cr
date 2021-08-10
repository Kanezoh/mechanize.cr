require "../spec_helper"

WebMock.stub(:get, "example.com/form/button").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <button type="submit" name="fstButton" value="fstButtonValue">
      <input  type="button" class="sndButton" value="sndButtonValue">
    </form>
  </body>
</html>
BODY
)

describe "Form Fields CheckBox" do
  agent = Mechanize.new

  page = agent.get("http://example.com/form/button")
  form = page.forms[0]

  it "returns buttons" do
    form.buttons.size.should eq 2
  end

  it "can be found by button_with method, argument type: Hash" do
    button2 = form.button_with({"class" => "sndButton"})
    button2.value.should eq "sndButtonValue"
  end

  it "can be found by button_with method, argument type: NamedTuple" do
    button2 = form.button_with({class: "sndButton"})
    button2.value.should eq "sndButtonValue"
  end
end

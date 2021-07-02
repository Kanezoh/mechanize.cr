require "../spec_helper"

WebMock.stub(:get, "example.com/form/select_list").to_return(body:
<<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <select name="pet" id="pet-select">
        <option value="dog">Dog</option>
        <option value="cat">Cat</option>
        <option value="hamster">Hamster</option>
      </select>
    </form>
  </body>
</html>
BODY
)

describe "Form Fields Select List" do
  agent = Mechanize.new
  page = agent.get("http://example.com/form/select_list")
  form = page.forms[0]

  it "returns selectboxes size" do
    form.selectboxes.size.should eq 1
  end

  selectbox = form.selectboxes[0].as(MechanizeCr::FormContent::SelectList)

  it "returns selectbox options size" do
    selectbox.options.size.should eq 3
  end

  it "returns selected values" do
    selectbox.values.empty?.should eq true
    selectbox.options[0].select
    selectbox.value.should eq "dog"
  end

  it "cannot select multiple values" do
    selectbox.options[0].select
    selectbox.value.should eq "dog"
    form.request_data.should eq "pet=dog"
    selectbox.options[1].select
    selectbox.value.should eq "cat"
    form.request_data.should eq "pet=cat"
  end
end

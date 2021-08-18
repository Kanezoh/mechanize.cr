require "../spec_helper"

WebMock.stub(:get, "example.com/form/multi_select_list").to_return(body: <<-BODY
<html>
  <head>
    <title>page_title</title>
  </head>
  <body>
    <form action="post_path" method="post" name="sample_form">
      <select name="pets" id="pet-select" multiple>
        <option value="dog">Dog</option>
        <option value="cat">Cat</option>
        <option value="hamster">Hamster</option>
      </select>
    </form>
  </body>
</html>
BODY
)

describe "Form Fields Multiple Select List Option" do
  agent = Mechanize.new
  page = agent.get("http://example.com/form/multi_select_list")
  form = page.forms[0]
  selectbox = form.selectboxes[0]

  it "can be clicked multiple option" do
    selectbox.values.empty?.should eq true
    option1 = selectbox.options[0].click
    selectbox.values.should eq ["dog"]
    option2 = selectbox.options[1].click
    selectbox.values.should eq ["dog", "cat"]
  end
end

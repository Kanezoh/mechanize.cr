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

describe "Form Fields Multiple Select List" do
  agent = Mechanize.new
  page = agent.get("http://example.com/form/multi_select_list")
  form = page.forms[0]

  it "returns selectboxes size" do
    form.selectboxes.size.should eq 1
  end

  selectbox = form.selectboxes[0]

  it "returns selectbox options size" do
    selectbox.options.size.should eq 3
  end

  it "returns selected values" do
    selectbox.values.empty?.should eq true
    selectbox.select_all
    selectbox.values.size.should eq 3
    selectbox.values.should eq ["dog", "cat", "hamster"]
    selectbox.select_none
    selectbox.values.empty?.should eq true
  end

  it "returns multiple selected values" do
    selectbox.select_all
    form.request_data.should eq "pets=dog&pets=cat&pets=hamster"
  end
end

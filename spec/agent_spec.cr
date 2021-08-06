require "./spec_helper"

describe "Mechanize Agent test" do
  it "can fill and submit form" do
    agent = Mechanize.new
    page = agent.get("http://example.com/form")
    form = page.forms[0]
    form.field_with("name").value = "foo"
    form.field_with("email").value = "bar"
    page = agent.submit(form)
    page.not_nil!.code.should eq 200
    page.not_nil!.body.should eq "success"
  end

  it "can fill and submit form with submit button" do
    agent = Mechanize.new
    page = agent.get("http://example.com/form")
    form = page.forms[0]
    form.field_with("name").value = "foo"
    form.field_with("email").value = "bar"
    submit_button = form.buttons[0]
    page = agent.submit(form, submit_button)
    page.not_nil!.code.should eq 200
    page.not_nil!.body.should eq "success with button"
  end

  it "can save history" do
    agent = Mechanize.new
    agent.get("http://example.com/")
    agent.history.size.should eq 1
    agent.history.last.title.should eq ""
    agent.get("http://example.com/form")
    agent.history.size.should eq 2
    agent.history.last.title.should eq "page_title"
  end

  it "can back previous page" do
    agent = Mechanize.new
    agent.get("http://example.com/")
    agent.get("http://example.com/form")
    agent.current_page.title.should eq "page_title"
    agent.back
    agent.current_page.title.should eq ""
  end
end

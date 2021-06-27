require "./spec_helper"

describe "Mechanize Page test" do
  it "return status code of request" do
    agent = Mechanize.new
    page = agent.get("http://example.com/")
    page.code.should eq 200
    page = agent.get("http://fail_example.com")
    page.code.should eq 500
  end

  it "return request body" do
    agent = Mechanize.new
    page = agent.get("http://example.com/")
    page.body.should eq ""
    page = agent.get("http://body_example.com")
    page.body.should eq "hello"
  end

  it "return page title" do
    agent = Mechanize.new
    page = agent.get("http://example.com/")
    page.title.should eq ""
    page = agent.get("http://example.com/form")
    page.title.should eq "page_title"
  end

  it "return page forms" do
    agent = Mechanize.new
    page = agent.get("http://example.com/form")
    page.forms.size.should eq 1
    page.forms.first.name.should eq "sample_form"
  end

  it "can detect form by using form_with method" do
    agent = Mechanize.new
    page = agent.get("http://example.com/form")
    form = page.form_with({"name" => "sample_form" })
    form.name.should eq "sample_form"
  end
end

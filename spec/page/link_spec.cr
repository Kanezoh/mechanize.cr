require "../spec_helper"

describe "Mechanize Page Link test" do
  it "returns href" do
    agent = Mechanize.new
    page = agent.get("http://example.com/link")
    link = page.links.first
    link.href.should eq "http://example.com/"
  end

  it "returns text" do
    agent = Mechanize.new
    page = agent.get("http://example.com/link")
    link = page.links.first
    link.text.should eq "link text"
  end

  it "is clickable and returns page" do
    agent = Mechanize.new
    page = agent.get("http://example.com/link")
    link = page.links.first
    page = link.click
    page.uri.to_s.should eq "http://example.com/"
  end
end

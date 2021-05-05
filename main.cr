require "./src/mechanize.cr"

agent = Mechanize.new
agent.request_headers = HTTP::Headers{"Foo" => "Bar"}
params = {"hoge" => "hoge"}
page = agent.get("http://example.com/", params: params)
#puts page.code
#puts page.body
#puts page.css("h1").first.inner_text
#puts page.title

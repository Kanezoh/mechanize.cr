require "./src/mechanize.cr"

agent = Mechanize.new
agent.request_headers = HTTP::Headers{"Foo" => "Bar"}
params = {"hoge" => "hoge"}
page = agent.get("https://kowabana.jp/users/sign_in/", params: params)
page.forms
#query = {"foo" => "foo_value", "bar" => "bar_value"}
#page = agent.post("http://example.com/", query: query)
#puts page.code
#puts page.body
#puts page.css("h1").first.inner_text
#puts page.title

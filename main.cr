require "./src/mechanize.cr"

agent = Mechanize.new
agent.request_headers = HTTP::Headers{"Foo" => "Bar"}
page = agent.get("https://example.com/")
puts page

require "./src/mechanize.cr"

agent = Mechanize.new
page = agent.get "http://example.com/"
puts page

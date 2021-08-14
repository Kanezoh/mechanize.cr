# mechanize.cr

This project is inspired by Ruby's [mechanize](https://github.com/sparklemotion/mechanize).
The purpose is to cover all the features of original one.
Now, mechanize.cr can automatically store and send cookies, fill and submit forms.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mechanize:
       github: Kanezoh/mechanize.cr
   ```

2. Run `shards install`

## Usage

### simple GET request

```crystal
require "mechanize"

agent = Mechanize.new
page = agent.get("http://example.com/")

puts page.code # => 200
puts page.body # => html
puts page.title # => Example Domain
```


### POST request

You can also send post request with data.

```crystal
require "mechanize"

agent = Mechanize.new
query = {"foo" => "foo_value", "bar" => "bar_value"}
page = agent.post("http://example.com/", query: query)
# => request body is foo=foo_value&bar=bar_value
```

### add query params, request_headers

You can add any query parameters and headers to requests.

```crystal
require "mechanize"

agent = Mechanize.new
agent.request_headers = HTTP::Headers{"Foo" => "Bar"}
params = {"hoge" => "hoge"}
page = agent.get("http://example.com/", params: params)
# The actual URL is http://example.com/?hoge=hoge
```

### fill and submit form

You can fill and submit form by using `field_with` and `submit`. It enables you to scrape web pages requiring login.

```crystal
require "mechanize"

agent = Mechanize.new
page = agent.get("#{web page contains login form}")
form = page.forms[0]
form.field_with("email").value = "tester@example.com"
form.field_with("password").value = "xxxxxx"
agent.submit(form)

agent.get("#{web page only logged-in users can see}"
```

### search node

You can use css selector to search html nodes by using `#css` method.
This method is from [lexbor](https://github.com/kostya/lexbor), so if you want to explore more, please refer the repository.

```crystal
puts page.css("h1").first.inner_text
```

## Contributing

1. Fork it (<https://github.com/Kanezoh/mechanize.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kanezoh](https://github.com/Kanezoh) - creator and maintainer

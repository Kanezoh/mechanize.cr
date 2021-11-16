class Mechanize
  module ElementMatcher
    macro elements_with(singular, plural = "")
    {% plural = "#{singular.id}s" if plural.empty? %}
    # search {{ plural.id }} which match condition.
    # 
    # Examples
    # ```
    # # if you specify String like "foo", it searches form which name is "foo".
    {% if ["form", "button"].includes?("#{singular.id}") %}
      # # like <{{ singular.id }} name="foo"></{{ singular.id }}>
    {% elsif "#{singular.id}" == "field" %}
    # # like <input name="foo"></input>
    {% elsif "#{singular.id}" == "radiobutton" %}
    # # like <input type="radio" name="foo"></input>
    {% else %}
    # # like <input type="{{ singular.id }}" name="foo"></input>
    {% end %}
    # page.{{ plural.id }}_with("foo")
    # # you can also specify tag's attribute and its' value by NamedTuple or Hash(String, String).
    {% if ["form", "button"].includes?("#{singular.id}") %}
    # # ex) <{{ singular.id }} class="foo"></{{ singular.id }}>
    {% elsif "#{singular.id}" == "field" %}
    # # ex) <input class="foo"></input>
    {% elsif "#{singular.id}" == "radiobutton" %}
    # # ex) <input type="radio" class="foo"></input>
    {% else %}
    # # ex) <input type="{{ singular.id }}" class="foo"></input>
    {% end %}
    # page.{{ plural.id }}_with("class" => "foo")
    # page.{{ plural.id }}_with(class: "foo")
    # ```
    def {{plural.id}}_with(criteria : String | NamedTuple | Hash(String,String))
      {{plural.id}}_with(criteria){}
    end

    def {{plural.id}}_with(criteria, &block)
      if criteria.is_a?(NamedTuple)
        criteria = criteria.to_h
      end
      if criteria.is_a?(String)
        criteria = {"name" => criteria}
      else
        criteria = criteria.each_with_object(Hash(String,String).new) do |(k, v), h|
          k = k.to_s
          h[k] = v
        end
      end
      f = {{plural.id}}.select do |elm|
        criteria.all? do |k,v|
          if k == "text"
            v == elm.node.inner_text
          else
            v == elm.node.fetch(k,"")
          end
        end
      end
      yield f
      f
    end

    # returns first element of `#{{ plural.id }}_with`
    def {{singular.id}}_with(criteria)
      f = {{plural.id}}_with(criteria)
      # TODO: Write correct error message.
      raise Mechanize::ElementNotFoundError.new(:{{singular.id}}, "") if f.empty?
      f.first
    end
  end
  end
end

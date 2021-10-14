module MechanizeCr::ElementMatcher
  macro elements_with(singular, plural = "")
    {% plural = "#{singular.id}s" if plural.empty? %}
    # search {{ singular.id }} which matches condition.
    # 
    # Examples
    # ```
    # # if you specify String like "foo", it searches form which name is "foo".
    # # like {<form name="foo"></form>}
    # page.form_with("foo") 
    # 
    # # you can specify tag's attribute and its' value by NamedTuple or Hash(String, String).
    # ex) <form class="foo"></form>
    # page.form_with("class" => "foo")
    # page.form_with(class: "foo")
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

    def {{singular.id}}_with(criteria)
      f = {{plural.id}}_with(criteria)
      # TODO: Write correct error message.
      raise ElementNotFoundError.new(:{{singular.id}}, "") if f.empty?
      f.first
    end
  end
end

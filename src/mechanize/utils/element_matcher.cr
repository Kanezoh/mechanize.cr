module MechanzeCr::ElementMatcher
  macro elements_with(singular, plural="")
    {% plural = "#{singular.id}s" if plural.empty? %}
    def {{plural.id}}_with(criteria)
      {{plural.id}}_with(criteria){}
    end

    def {{plural.id}}_with(criteria, &block)
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

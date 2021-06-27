module MechanzeCr::ElementMatcher
  macro elements_with(singular)
    {% plural = "#{singular.id}s" %}
    def {{plural.id}}_with(criteria)
      {{plural.id}}_with(criteria){}
    end

    def {{plural.id}}_with(criteria, &block)
      value = Hash(String,String).new
      if criteria.is_a?(String)
        criteria = {"name" => criteria}
      else
        criteria = criteria.each_with_object(Hash(String,String).new) do |(k, v), h|
          h[k] = v
          # TODO: to deal with when key is "text"
          #case k = k.to_s
          #when "id"
          #  h["id"] = v
          #when "class"
          #  h["class"] = v
          #else
          #  h[k] = v
          #end
        end
      end
      f = {{plural.id}}.select do |elm|
        criteria.all? do |k,v|
          v === elm.node.fetch(k,"")
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

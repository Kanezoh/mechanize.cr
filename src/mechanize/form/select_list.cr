require "./multi_select_list"

# This class represents <select> which is not multiple
class Mechanize::FormContent::SelectList < Mechanize::FormContent::MultiSelectList
  def initialize(node)
    super node
    # only one selected option is allowed
    if selected_options.size > 1
      selected_options.reverse[1..selected_options.size].each do |o|
        o.unselect
      end
    end
  end

  def value
    if values.size > 0
      values.last
    elsif options.size > 0
      options.first.value
    else
      nil
    end
  end

  def value=(new_value)
    values = new_value
  end

  def query_value
    value ? [[name, value.not_nil!]] : nil
  end
end
